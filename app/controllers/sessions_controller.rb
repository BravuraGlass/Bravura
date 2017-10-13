class SessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]
  skip_before_action :late_access, only: [:create, :new]


  def new
    if current_user
      redirect_back_or_to jobs_url
    else
      render :layout => 'pages'
    end
  end

  def create
    user = login(params[:email], params[:password])

    if user
      redirect_back_or_to jobs_url, :notice => "Welcome back #{user["firstname"]}"
    else
      redirect_back_or_to login_url, :alert => "Email or password was invalid"
    end
  end

  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end
end
