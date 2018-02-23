class AuditLogsController < ApplicationController

  before_action :require_non_worker
  before_action :init_search, only: [:index]

  def index  
    @show_active = params[:active].eql?('false') ? false : true
    @users = User.order("first_name, last_name")
    
    @jobs = []
    
    if params[:category] == 'job'
      @jobs = Job.where("active = ?", true)
    else  
      Job.where("active = ?", true).each do |job|
        @jobs << job unless job.fabrication_order.nil?
      end  
    end  
    @status = Status.where(category: [:products,:tasks,:rooms,:jobs]).order(:category)
    @statuses_product = @status.map{|x| x if x.category == "products"}.compact
    @statuses_collection = [["ALL Materials", "category,material"]]
    @statuses_collection += @statuses_product.collect {|sta| [sta.name_alias, sta.name]}
    @statuses_task = @status.map{|x| x if x.category == "tasks"}.compact
    @statuses_collection += [["ALL Tasks", "category,task"]]
    @statuses_collection += @statuses_task.collect {|sta| [sta.name_alias, sta.name]}
    @statuses_rooms = @status.map{|x| x if x.category == "rooms"}.compact
    @statuses_collection += [["ALL Rooms", "category,room"]]
    @statuses_collection += @statuses_rooms.collect {|sta| [sta.name_alias, sta.name]}
    @statuses_jobs = @status.map{|x| x if x.category == "jobs"}.compact
    @statuses_collection += [["ALL Jobs", "category,job"]]
    @statuses_collection += @statuses_jobs.collect {|sta| [sta.name_alias, sta.name]}
    
    
    
    @audit_logs = AdvancedSearch.new.audit_logs(params, 1, 1000)
  end

  def init_search
    if params[:date].blank? and params[:filter] != "all"
      @filter_today = true
      params[:date] = Time.zone.now.strftime("%Y-%m-%d")
    elsif params[:date].blank?
      @filter_all = true
    elsif params[:date] == Time.zone.now.strftime("%Y-%m-%d")
      @filter_today = true
    elsif params[:date] == (Time.zone.now - 1.day).strftime("%Y-%m-%d")  
      @filter_yesterday = true
    end    
    
    @selected_date = params[:date]
    
  end

  def audit_job
    @job = Job.find(params[:id])
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def audit_room
    @room = Room.find(params[:id])
    respond_to do |format|
      format.js {render layout: false}
    end
  end
  
  def audit_product
    @product = Product.find(params[:id])
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def audit_section
    @section = ProductSection.find(params[:id])
    respond_to do |format|
      format.js {render layout: false}
    end
  end

end
