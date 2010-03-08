# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  email               :string(255)     not null
#  crypted_password    :string(255)     not null
#  password_salt       :string(255)     not null
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)     not null
#  perishable_token    :string(255)     not null
#  login_count         :integer         default(0), not null
#  failed_login_count  :integer         default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::BCrypt
    config.perishable_token_valid_for = 1.hour
  end
    
  has_many :quizzes, :dependent => :destroy
  
  has_many :questions, :through => :quizzes
    
  has_many :participations, :dependent => :destroy
  
  has_many :participating_quizzes, :through => :participations,
                                   :source => :quiz
  
  has_many :answers, :class_name => 'UserAnswer',
                     :dependent => :destroy
  
  validates_presence_of :name
  
  validates_uniqueness_of :name, :case_sensitive => false
  
  def participate!(quiz)
    participations.create!(:quiz => quiz)
  end
  
  def unparticipate!(quiz)
    participations.find_by_quiz_id(quiz).destroy
  end
  
  def participating?(quiz)
    participations.exists?(:quiz_id => quiz)
  end
  
  def answer_question!(question, params)
    answer = question.answers.find(params[:user_answer][:answer_id])
    answers.find_or_create_by_question_id_and_answer_id(question.id, answer.id)
  end
  
  def all_answered?(quiz)
    total_answered(quiz) == quiz.questions.count
  end
  
  def total_answered(quiz)
    answers.count(:conditions => { :question_id => quiz.question_ids })
  end
  
  def can_edit_answer?(answer)
    question_ids.include?(answer.question_id)
  end
  
  def can_edit_question?(question)
    questions.include?(question)
  end
  
  def can_edit_quiz?(quiz)
    quizzes.include?(quiz)
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Emailer.deliver_password_reset_instructions(self)
  end
    
  def find_participation(quiz)
    participations.find_by_quiz_id(quiz)
  end
end
