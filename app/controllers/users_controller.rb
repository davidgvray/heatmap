class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:rpx_token] # RPX does not pass Rails form tokens...
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update, :destroy]
  before_filter :find_user, :only => :show
  

  # user_data
  # found: {:name=>'John Doe', :username => 'john', :email=>'john@doe.com', :identifier=>'blug.google.com/openid/dsdfsdfs3f3'}
  # not found: nil (can happen with e.g. invalid tokens)
  def rpx_token
     raise "hackers?" unless data = RPXNow.user_data(params[:token])
     logger.info { "data #{data.inspect}" }
     # = User.find_by_identifier(data[:identifier]) || User.create!(data)
    
      @user = User.find_by_identifier(data[:identifier])
      if !@user
        @user = User.find_by_email(data[:email])

        if @user
          @user.identifier = data[:identifier]
          @user.save
        else
          name = data[:name] || data[:username]
          mail = data[:email] || "noemail@noemail.com"

          #try and find a good username
          if !User.find_by_username(data[:username])
            username = data[:username]
          elsif !User.find_by_username(name)
            username = name
          else
            username = mail
          end
          
          password = (0...8).map{65.+(rand(25)).chr}.join
          
          newdata = {:name => name, :email => mail, :identifier => data[:identifier], :username => username, :password => password, :password_confirmation => password}
          @user = User.new(newdata)
          
          logger.info { "new data #{newdata.inspect}" }
          
          raise "Couldn't create new account" unless @user.save
        end
      end
      
    UserSession.create(@user,true)

    redirect_to dashboard_path
  end

  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome! Glad you made it"
      redirect_back_or_default root_url
    else
      flash[:error] = 'There was a problem with your form'
      render :new
    end
  end
 
  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:success] = 'Account updated'
      redirect_to account_url
    else
      render :edit
    end
  end
  
  def destroy
    @current_user.destroy
    redirect_to root_url
  end
  
  private
  
  def find_user
    @user = User.find_by_username(params[:username])
    
    unless @user
      render :text => 'User not found.', :status => 404
    end
  end
end