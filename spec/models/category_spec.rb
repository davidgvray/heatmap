# == Schema Information
#
# Table name: categories
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  quizzes_count :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Category do
  fixtures :categories
  
  should_have_many :quizzes
  
  should_validate_presence_of :name
  
  should_validate_uniqueness_of :name
  
  describe '#for_select' do
    it { lambda { Category.for_select }.should_not raise_exception }
  end
end
