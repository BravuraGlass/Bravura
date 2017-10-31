require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class WorkingLogsController < ApplicationController
  include AuditableController
  skip_before_action :require_login, only: [:checkin, :checkout], if: -> { request.format.json? }
  before_action :api_login_status, only: [:checkin, :checkout], if: -> { request.format.json? } 
  
  def index
    if current_user.type_of_user == "0"
      @working_logs = WorkingLog.order("checkin_time")
    else
      render plain: "you are not authorized to access this page"
    end    
  end  
  
  def checkin_barcode
    respond_to do |format|      
      barcode = Barby::Code128B.new(CHECKIN_BARCODE)
      format.png { send_data barcode.to_png,type: "image/png", disposition: 'inline' }
    end  
  end  
  
  def checkout_barcode
    respond_to do |format|      
      barcode = Barby::Code128B.new(CHECKOUT_BARCODE)
      format.png { send_data barcode.to_png,type: "image/png", disposition: 'inline' }
    end  
  end  
  
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
            checkin_time: @working_log.api_readable_checkin,
            checkin_method: @working_log.checkin_method,
            location: @working_log.location 
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
            checkout_time: @working_log.api_readable_checkout,
            checkout_method: @working_log.checkout_method
          }

        }
      end  
      
      format.json {render json: result}
    end 
  end  
  
  # for testing purpose only
  def destroy_all
    if Rails.env.to_s == "development" or request.host.include?("heroku")
      WorkingLog.destroy_all
      render plain: "Working logs data has been destroyed"
    else
      render plain: "you are not authorized to access this page"
    end      
  end  
  
  protected
  
  def api_params
    params.permit(:access_id,:longitude,:latitude,:barcode, :format, :access_token)
  end 
    
end
