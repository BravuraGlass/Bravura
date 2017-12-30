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
      should_checkin_first
    end  
  end

  def should_checkin_first
    if (controller_name == "working_logs" && (action_name == "checkin" or action_name == "checkout")) ||
       (controller_name == "sessions" && ["create","destroy"].include?(action_name))
    else
      unless @api_user.nil?
        if @api_user.checkin_status == false && !@api_user.always_access
          result = {
            status: :failed,
            message: "access denied, please clock in first",
            data: nil,
          }
          render json: result  
        end
      end
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
      if @current_user.checkin_status == false && !current_user.always_access #&& Rails.env == "production"
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

