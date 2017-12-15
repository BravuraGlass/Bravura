class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :require_login

  before_action :restrict_delete, only: [:destroy]
  
  protected
  
  def api_login_status
    
    api_login =  User.api_login(params)
    
    if api_login [:status] == false
       result = {
         status: :failed,
         message: "access denied, please login first",
         data: nil,
       }
       render json: result  
    else
      @api_user = api_login[:user]        
    end  
  end  
  
  def api_response(status, message, data)
    return {
      status: status,
      message: message,
      data: data
    }
  end  
  
  def require_admin
    if current_user.admin?
    else
      render plain: "you are not authorized to access this page" and return
    end    
  end  

  def require_non_worker
    if current_user.non_worker?
    else
      render plain: "you are not authorized to access this page" and return
    end    
  end
  
  def require_admin_api
    user = User.where("access_token =? AND id=? AND token_expired >= ?", params[:access_token], params[:access_id], Date.today)[0]
    
    if user.admin?
    else
      render json: api_response(:failed, "you are not authorized to access this page", nil) and return
    end    
  end  

  private

  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end
  
  def require_login
    super
  
    @current_user = eval("current_user")
    
    unless @current_user.nil?
      last_log_today = WorkingLog.where("submit_date=? AND user_id = ?", Time.zone.now.strftime("%Y%m%d"), current_user.id).order("submit_time DESC")[0]
    
      if last_log_today.nil?
        uaccess = false
      else
        if last_log_today.checkin_or_checkout == "checkin"
          uaccess = true
        else
          uaccess = false  
        end
      end    
    
      if uaccess == false && !current_user.always_access #&& Rails.env == "production"
        logout
        redirect_back_or_to login_url, :alert => "can't access Bravura without clock in first"
      end      
    end    
  end
  
  def restrict_delete 
    # if use is not an admin
    unless current_user.type_of_user.eql?("0")
      return
    end
  end
end

