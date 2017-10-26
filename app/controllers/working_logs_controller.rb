class WorkingLogsController < ApplicationController
  include AuditableController
  skip_before_action :require_login, only: [:checkin, :checkout], if: -> { request.format.json? }
  before_action :api_login_status, only: [:checkin, :checkout], if: -> { request.format.json? } 
  
  def checkin
    
    @working_log = WorkingLog.checkin(user_id: api_params[:access_id], latitude: api_params[:latitude], longitude: api_params[:longitude], barcode: api_params[:barcode])
      
    respond_to do |format|
      
      if @working_log.errors.size > 0
        result = {
          status: :failed,
          message: @working_log.errors.full_messages.join(","),
          data: nil
        }
      else
        result = {
          status: :success,
          message: nil,
          data: {
            user: {
              id: @working_log.user_id,
              first_name: @working_log.user.first_name,
              last_name: @working_log.user.last_name
            },
            checkin_time: @working_log.checkin_time,
            checkin_method: @working_log.checkin_method
          }

        }
      end  
      
      format.json {render json: result}
    end  
    
  end
  
  def checkout
    @working_log = WorkingLog.checkout(user_id: api_params[:access_id], latitude: api_params[:latitude], longitude: api_params[:longitude], barcode: api_params[:barcode])
      
    respond_to do |format|
      
      if @working_log.errors.size > 0
        result = {
          status: :failed,
          message: @working_log.errors.full_messages.join(","),
          data: nil
        }
      else
        result = {
          status: :success,
          message: nil,
          data: {
            user: {
              id: @working_log.user_id,
              first_name: @working_log.user.first_name,
              last_name: @working_log.user.last_name
            },
            checkout_time: @working_log.checkout_time,
            checkout_method: @working_log.checkout_method
          }

        }
      end  
      
      format.json {render json: result}
    end 
  end  
  
  protected
  
  def api_params
    params.permit(:access_id,:longitude,:latitude,:barcode, :format, :access_token)
  end 
    
end
