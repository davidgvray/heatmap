class SurveySectionsController < ApplicationController
  before_filter :require_user, :except => :show
  before_filter :find_survey
  before_filter :find_survey_section, :except => [:new, :create]
  before_filter :authorize_survey, :except => [:show]
  before_filter :authorize_survey_section, :except => [:new, :create]
  
  
  def new
    @survey_section = SurveySection.new
  end
  
  def create
    @survey_section = @survey.survey_sections.build(params[:survey_section])
    
    logger.info("what what")
    if @survey_section.save
      redirect_to survey_url(@survey)
    else
      logger.info("failed")
      render :new
    end
  end
  #   
  # def show
  #   @answer = Answer.new
  #   @answers = @question.answers
  #   
  #   if participant?
  #     @user_answer = current_user.answers.find_or_initialize_by_question_id(@question)
  #     @total_answered = current_user.total_answered(@survey)
  #     @total_questions = @survey.questions.count
  #     @participation = current_user.find_participation(@survey)
  #   elsif suggester?
  #     @suggested_questions = current_user.suggested_questions_for_survey(@survey)
  #   end
  # end
  # 
  # def edit
  # end
  # 
  # def update
  #   if @question.update_attributes(params[:question])
  #     redirect_to survey_question_url(@survey, @question)
  #   else
  #     render :edit
  #   end
  # end
  # 
end
