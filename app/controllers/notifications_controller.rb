class NotificationsController < ApplicationController
  #before_action :require_admin
  
  skip_before_action :require_login, if: -> { request.format.json? }
  before_action :api_login_status, if: -> { request.format.json? }  
  before_action :set_notifications

  def create
    respond_to do |format|
      format.json { render json: api_response(:success, nil, @notifications)}
    end
  end

  private
  def notifications_params
    params.permit(:device_type, :device_token)
  end

  def set_notifications
    notification = Notification.new(notifications_params)
    
    if notification.valid?
      user = notification.submit(@api_user)
      @notifications = user.as_json(only: [:id, :email, :first_name, :last_name, :device_type, :device_token])
                                
    else
      render json: api_response(:failed, notifications.errors.full_messages.join(', '), nil) and return
    end
  end
end
