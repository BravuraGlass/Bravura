class AuditLogsController < ApplicationController
  def index
=begin    
    @show_active = params[:active].eql?('false') ? false : true
    @users = User.order("first_name, last_name")
    @jobs = Job.where("active = ?", true)

    if params[:date].blank?
      @filter_all = true
    elsif params[:date] == Time.zone.now.strftime("%Y-%m-%d")
      @filter_today = true
    elsif params[:date] == (Time.zone.now - 1.day).strftime("%Y-%m-%d")  
      @filter_yesterday = true
    end    
    
    @selected_date = params[:date]
    
    if params[:category].blank? or params[:category] == "material"
      thecategory = "ProductSection"
    elsif params[:category] == "task"
      thecategory = "Product"
    else
      thecategory = params[:category].titleize
    end      
    
    @where = ""
    if params[:date].blank?
      @where +=  "auditable_type = '#{thecategory}'"    
    else
      @where +=  "auditable_type = '#{thecategory}' AND DATE(created_at) = '#{params[:date]}'"
    end     
    
    if params[:user].blank? == false and params[:address].blank? == false
    @where += " AND "
   
    if params[:user].blank? == false and params[:address].blank? == false
      @where += "user_name = '#{params[:user]}'"
    end  
    
    Rails.logger.info "SQL #{@where}"
    @audit_logs = AuditLog.where(@where)
=end
    render plain: "test"    
  end  
end
