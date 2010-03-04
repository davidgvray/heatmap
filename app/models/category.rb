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

class Category < ActiveRecord::Base
  has_many :quizzes
  
  validates_presence_of :name
  
  validates_uniqueness_of :name, :case_sensitive => false
end
