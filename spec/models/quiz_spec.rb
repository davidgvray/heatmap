# == Schema Information
#
# Table name: quizzes
#
#  id                   :integer         not null, primary key
#  category_id          :integer
#  user_id              :integer
#  title                :string(255)
#  description          :text
#  questions_count      :integer         default(0)
#  created_at           :datetime
#  updated_at           :datetime
#  permalink            :string(255)
#  participations_count :integer         default(0)
#  questions_updated_at :datetime
#  last_viewed          :datetime
#

require 'spec_helper'

describe Quiz do
  fixtures :quizzes
  
  should_not_allow_mass_assignment_of :user_id
  
  should_belong_to :category,
                   :user,
                   :owner
  
  should_have_many :questions,
                   :suggested_questions,
                   :user_answers,
                   :participations,
                   :participants
  
  should_validate_presence_of :title,
                              :permalink
  
  should_validate_uniqueness_of :title
  
  should_have_scope :recently_added, :limit => 10,
                                     :order => 'created_at DESC'
                                     
  should_have_scope :recently_updated, :limit => 10,
                                       :order => 'questions_updated_at DESC'
                                       
  should_have_scope :recently_viewed, :limit => 15,
                                      :order => 'last_viewed DESC'
                                     
  describe 'custom validations' do    
    it 'should make the permalink' do
      q = quizzes(:rails)
      q.title = 'This IS a TEST'
      q.save
      q.reload.permalink.should eql('this-is-a-test')
    end
  end
  
  describe '#percentage_answered_correctly' do
    it { quizzes(:ruby).percentage_answered_correctly.should be_zero }
    it { quizzes(:rails).percentage_answered_correctly.should eql(100) }
  end
  
  describe '#tags' do
    fixtures :tags, :taggings
    
    it { quizzes(:rails).tags.should include(tags(:rails)) }
    it { quizzes(:rails).tags.should_not include(tags(:ruby)) }
    
    it { quizzes(:ruby).tags.should include(tags(:ruby)) }
    it { quizzes(:ruby).tags.should_not include(tags(:rails)) }
  end
  
  describe '#next_number' do
    before { @quiz = quizzes(:rails) }
    
    describe 'with existing questions' do
      it 'should return 12346' do
        @quiz.next_number.should eql(12346)
      end
    end
    
    describe 'with no existing questions' do
      before { Question.delete_all }
      
      it 'should return 1' do
        @quiz.next_number.should eql(1)
      end
    end
  end
  
  describe '#to_param' do    
    it 'should return the id and permalink' do
      quiz = Quiz.new
      mock(quiz) do
        id { 1 }
        permalink { 'test' }
      end
      
      quiz.to_param.should eql('1-test')
    end
  end
end
