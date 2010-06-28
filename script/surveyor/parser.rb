require 'activesupport' # for pluralize, humanize in ActiveSupport::CoreExtensions::String::Inflections
module SurveyParser
  class Parser
    @@models = %w(survey section question_group question answer dependency dependency_condition validation validation_condition)
  
    # Require base and all models
    (%w(base) + @@models).each{|m| require File.dirname(__FILE__) + "/#{m}"}

    # Attributes
    attr_accessor :salt, :surveys, :grid_answers
    @@models.each{|m| attr_accessor "#{m.pluralize}_yml".to_sym } # for fixtures
    (@@models - %w(dependency_condition validation_condition)).each {|m| attr_accessor "current_#{m}".to_sym} # for current_model caches
  
    # Class methods
    def self.parse(file_name)
      self.define_counter_methods(@@models)
      puts "\n--- Parsing '#{file_name}' ---"
      parser = SurveyParser::Parser.new
      parser.instance_eval(File.read(file_name))
      parser.to_files
      puts "--- End of parsing ---\n\n"
    end

    # new_survey_id, new_section_id, etc.
    def self.define_counter_methods(names)
      names.each do |name|
        define_method("new_#{name}_id") do
          instance_variable_set("@last_#{name}_id", instance_variable_get("@last_#{name}_id") + 1)
        end
      end
    end
  
    # Instance methods
    def initialize
      self.salt = Time.now.strftime("%Y%m%d%H%M%S")
      self.surveys = []
      self.grid_answers = []
      initialize_counters(@@models)
      initialize_fixtures(@@models.map(&:pluralize), File.join(RAILS_ROOT, "surveys", "fixtures"))
    end
    
    # @last_survey_id, @last_section_id, etc.
    def initialize_counters(names)
      names.each{|name| instance_variable_set("@last_#{name}_id", 0)}
    end

    # @surveys_yml, @sections_yml, etc.
    def initialize_fixtures(names, path)
      names.each {|name| file = instance_variable_set("@#{name}_yml", "#{path}/#{name}.yml"); File.truncate(file, 0) if File.exist?(file) }
    end

    # This method_missing does all the heavy lifting for the DSL
    def method_missing(missing_method, *args, &block)
      method_name, reference_identifier = missing_method.to_s.split("_", 2)
      opts = {:method_name => method_name, :reference_identifier => reference_identifier}
      case method_name
      when "survey"
        self.current_survey = Survey.new(self, args, opts)
        evaluate_the "survey", &block
    
      when "section"
        self.current_section = Section.new(self.current_survey, args, opts.merge({:display_order => current_survey.sections.size + 1}))
        evaluate_the "section", &block
      
      when "group", "g", "grid", "repeater"
        self.current_question_group = QuestionGroup.new(self.current_section, args, opts)
        evaluate_the "question_group", &block
      
      when "question", "q", "label", "image"
        drop_the &block
        self.current_question = Question.new(self.current_section, args, opts.merge(:question_group_id => current_question_group ? current_question_group.id : nil))
        add_grid_answers if in_a_grid?
      
      when "dependency", "d"
        drop_the &block
        self.current_dependency = Dependency.new(self.current_question_group || current_question, args, opts)
      
      when "condition", "c"
        drop_the &block
        raise "Error: No current dependency or validation for this condition" if self.current_dependency.nil? && self.current_validation.nil?
        if self.current_dependency.nil?
          self.current_validation.validation_conditions << ValidationCondition.new(self.current_validation, args, opts)
        else
          self.current_dependency.dependency_conditions << DependencyCondition.new(self.current_dependency, args, opts)
        end
      
      when "answer", "a"
        drop_the &block
        if in_a_grid?
          self.grid_answers << Answer.new(nil, args, opts.merge(:display_order => grid_answers.size + 1))
        else
          raise "Error: No current question" if self.current_question.nil?
          self.current_answer = Answer.new(self.current_question, args, opts.merge(:display_order => current_question.answers.size + 1))
        end
    
      when "validation", "v"
        drop_the &block
        self.current_validation = Validation.new(self.current_answer, args, opts)

      else
        raise "  ERROR: '#{missing_method}' not valid method"
    
      end
    end

    def drop_the(&block)
      raise "Error, I'm dropping the block like it's hot" if block_given?
    end
  
    def evaluate_the(model, &block)
      raise "Error: A #{model.humanize} cannot be empty" unless block_given?
      self.instance_eval(&block)
      self.send("clear_current", model)
    end
  
    def clear_current(model)
      # puts "clear_current #{model}"
      case model
      when "survey"
        self.current_survey.reconcile_dependencies unless current_survey.nil?
      when "question_group"
        self.grid_answers = []
        clear_current("question")
      when "question"
        @current_dependency = nil
      when "answer"
        @current_validation = nil
      end
      instance_variable_set("@current_#{model}", nil)
      "SurveyParser::#{model.classify}".constantize.send(:children).each{|m| clear_current(m.to_s.singularize)}
    end
  
    def current_survey=(s)
      clear_current "survey"
      self.surveys << s
      @current_survey = s
    end
    def current_section=(s)
      clear_current "section"
      self.current_survey.sections << s
      @current_section = s 
    end
    def current_question_group=(g)
      clear_current "question_group"
      self.current_section.question_groups << g
      @current_question_group = g
    end  
    def current_question=(q)
      clear_current "question"
      self.current_section.questions << q
      @current_question = q
    end
    def current_dependency=(d)
      raise "Error: No question or question group" unless (dependent = self.current_question_group || self.current_question)
      dependent.dependency = d
      @current_dependency = d
    end
    def current_answer=(a)
      raise "Error: No current question" if self.current_question.nil?
      self.current_question.answers << a
      @current_answer = a
    end  
    def current_validation=(v)
      clear_current "validation"
      self.current_answer.validation = v
      @current_validation = v
    end

    def in_a_grid?
      self.current_question_group and self.current_question_group.display_type == "grid"
    end
  
    def add_grid_answers
      self.grid_answers.each do |grid_answer|
        my_answer = grid_answer.dup
        my_answer.id = new_answer_id
        my_answer.question_id = self.current_question.id
        my_answer.parser = self
        self.current_answer = my_answer
      end
    end

    def to_files
      self.surveys.compact.map(&:to_file)
    end

  end
end