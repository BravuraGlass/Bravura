class SessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]
  skip_before_action :late_access, only: [:create, :new]
  before_action :use_unsafe_params, only: [:create]

  def new
    if current_user
      redirect_back_or_to jobs_url
    else
      render :layout => 'pages'
    end
  end

  def create
    user = login(params[:email], params[:password])
    
    respond_to do |format|
      format.html do
        if user
          redirect_back_or_to jobs_url, :notice => "Welcome back #{user["firstname"]}"
        else
          redirect_back_or_to login_url, :alert => "Email or password was invalid"
        end
      end  
      
      format.json do 
        if user
          user.generate_token
          result =  {
            status: :success,
            data: {
              id: user.id,
              access_token: user.access_token,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              phonenumber: user.phonenumber,
              address: user.address      
            },
            message: nil
          }
        else
          result = {
            status: :failed,
            data: nil,
            message: "Email, password was invalid or access token has expired"
          }
        end    
        render json: result
      end
    end      
  end

  def params
    @_dangerous_params || super
  end
  
  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end
  
  private

  def use_unsafe_params
    @_dangerous_params = request.parameters
  end
end
