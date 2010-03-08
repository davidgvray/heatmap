require 'spec_helper'

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include ActionController::UrlWriter
  
  describe '#password_reset_instructions' do
    fixtures :users
    
    before do
      @user = users(:justin)
      @email = Emailer.create_password_reset_instructions(@user)
    end
    
    it { @email.should deliver_from("Quizdoo <noreply@quizdoo.com>") }
    it { @email.should deliver_to(@user.email) }
    it { @email.should have_subject('[Quizdoo] Password Reset Instructions') }
    
    it 'should contain the password reset link' do
      url = edit_password_reset_url @user.perishable_token,
                                    :host => 'quizdoo.com',
                                    :protocol => 'http'
      
      @email.should have_body_text(url)
    end
  end
end