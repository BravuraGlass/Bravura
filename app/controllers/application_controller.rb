class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :require_login
  #before_action :late_access
  before_action :restrict_delete, only: [:destroy]
  
  protected
  
  def api_login_status
    
    if User.api_login_status(params) == false
       result = {
         status: :failed,
         message: "access denied, please login first",
         data: nil,
       }
       render json: result
    end  
  end  

  private

  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def late_access
    hour = Time.now.utc.hour
    if (hour >= 18 || hour <= 7) && !current_user.try(:late_access)
      logout
      redirect_back_or_to login_url, :alert => "Your account has no access at night"
    end
  end

  def restrict_delete 
    # if use is not an admin
    unless current_user.type_of_user.eql?("0")
      return
    end
  end
end

