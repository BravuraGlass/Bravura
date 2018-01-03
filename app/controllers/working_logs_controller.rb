require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class WorkingLogsController < ApplicationController
  include AuditableController
  skip_before_action :require_login, only: [:checkin, :checkout, :user_checkin_status], if: -> { request.format.json? }
  before_action :api_login_status, only: [:checkin, :checkout, :user_checkin_status], if: -> { request.format.json? }
  before_action :require_admin, only: [:report, :report_detail, :index] 
  
  def index
    @working_logs = WorkingLog.order("submit_time DESC").joins(:user).where("users.id IS NOT NULL") 
    @need_libs = ['maps']
  end  
  
  def report
    @week = report_params[:week].nil? ? "last_week" : report_params[:week] 
    @years = (2017..(Time.now.year)).to_a
    @weeks = [["Current Week","current_week"],["Last Week","last_week"]]
    
    start_end_week
    
    @working_log_arr = WorkingLog.report(@wstart, @wend)
    
  end  

  def user_checkin_status
    response_json = if @api_user
      api_response(:success, nil, 
        @api_user.as_json(only: [:first_name, :last_name, :email])
                 .merge({checkin_status: @api_user.checkin_status})
      )
    else
      api_response(:failed, "you are not authorized to access this page", nil)
    end

    respond_to do |format|
      format.json { render json: response_json}
    end
  end
  
  def destroy_report
    @working_logs = WorkingLog.where("user_id=? AND id IN (?)", report_params[:user_id], report_params[:ids].split(",") )
    @working_logs.destroy_all
    
    flash[:notice] = "Working Log was sucessfully deleted"
    redirect_to report_detail_working_logs_path(user_id: report_params[:user_id], week: report_params[:week])
  end  
  
  def report_detail
    @week = report_params[:week]
    start_end_week
    
    @user = User.find(report_params[:user_id])
    @working_log_arr = WorkingLog.report_detail(report_params[:user_id],@wstart, @wend)  
  end
  
  def new_report_detail

    @user = User.find(params[:user_id])
    if params[:week] == "current_week"
      sday = Date.today.beginning_of_week(:sunday)
      eday = sday + 6.day
      arr_dates = (sday..eday).to_a
    elsif params[:week] == "last_week"
      sday = Date.today.prev_week.beginning_of_week(:sunday)
      eday = sday + 6.day
      arr_dates = (sday..eday).to_a
    end     
    
    @dates = arr_dates.collect {|thedate| [thedate.strftime("%A %B %d, %Y"),thedate.to_s.gsub("-","")]}
  end  
  
  def edit_report_detail
    @working_logs = WorkingLog.where("id IN (?) AND user_id=?", report_params[:ids].split(","), report_params[:user_id]).order("checkin_or_checkout ASC")
    
    if @working_logs.size == 1      
      ### vars
      
      @start_hour =  @working_logs[0].start_hour
      @start_minute =  @working_logs[0].start_minute
      @start_second =  @working_logs[0].start_second
      
      @finish_hour =  @working_logs[0].finish_hour
      @finish_minute =  @working_logs[0].finish_minute
      @finish_second =  @working_logs[0].finish_second
      
      @start_method = @working_logs[0].checkin_or_checkout == "checkin" ? @working_logs[0].submit_method : "manual"
      @finish_method = @working_logs[0].checkin_or_checkout == "checkout" ? @working_logs[0].submit_method : "manual"
      
    elsif @working_logs.size == 2
      
      @start_hour =  @working_logs[0].start_hour
      @start_minute =  @working_logs[0].start_minute
      @start_second =  @working_logs[0].start_second
      
      @finish_hour =  @working_logs[1].finish_hour
      @finish_minute =  @working_logs[1].finish_minute
      @finish_second =  @working_logs[1].finish_second
      
      @start_method = @working_logs[0].submit_method
      @finish_method = @working_logs[1].submit_method
    end
    
    
  end  
  
  def create_report_detail
    rs = WorkingLog.create_report_detail(params)
    
    if rs[:errors].size > 0
      flash[:alert] = "Invalid, #{rs[:errors].join(' & ')}"
      redirect_to new_report_detail_working_logs_path(user_id: report_params[:user_id], week: report_params[:week], date: params[:date])
    else
      flash[:notice] = "Working Log was sucessfully updated"
      redirect_to report_detail_working_logs_path(user_id: report_params[:user_id], week: report_params[:week])
    end    
  end 
  
  def update_report_detail
    rs = WorkingLog.update_report_detail(params)
    
    if rs[:errors].size > 0
      flash[:alert] = "Invalid, #{rs[:errors].join(' & ')}"
      redirect_to edit_report_detail_working_logs_path(ids: report_params[:ids], user_id: report_params[:user_id], week: report_params[:week])
    else
      flash[:notice] = "Working Log was sucessfully updated"
      params_redirect = {user_id: report_params[:user_id], week: report_params[:week]}
      params_redirect.merge!({scroll: true}) if params[:scroll]
      redirect_to report_detail_working_logs_path(params_redirect)
    end    
  end  
  
  protected
  
  def start_end_week
    if @week == "current_week"
      @wstart = Date.today.beginning_of_week(:sunday).to_s.gsub("-","").to_i
      @wend = (Date.today.beginning_of_week(:sunday) + 6.day).to_s.gsub("-","").to_i
    elsif @week == "last_week"
      @wstart = Date.today.prev_week.beginning_of_week(:sunday).to_s.gsub("-","").to_i
      @wend = (Date.today.prev_week.beginning_of_week(:sunday) + 6.day).to_s.gsub("-","").to_i
    end  
  end
  
  public   
  
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
            checkin_time: @working_log.readable_time,
            checkin_method: @working_log.submit_method,
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
            checkout_time: @working_log.readable_time,
            checkout_method: @working_log.submit_method,
            location: @working_log.location 
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
  
  def report_params
    params.permit(:week, :user_id, :ids, :start_hour, :start_minute, :start_second, :finish_hour, :finish_minute, :finish_second, :start_method, :finish_method)
  end  
    
end
