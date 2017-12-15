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
    
    if params[:category] == "material" or params[:category].blank?
      @statuses = Status.where(category: Status.categories[:products])
    elsif params[:category] == "task"
      @statuses = Status.where(category: Status.categories[:tasks])
    else
      @statuses = Status.where(category: Status.categories[params[:category].pluralize])
    end    
    
    unless @statuses.collect {|sta| sta.name}.include?(params[:status])
      params[:status] = nil    
    end  
    
    @audit_logs = AdvancedSearch.new.audit_logs(params, 1, 1000)
  end

  def init_search
    if params[:date].blank?
      @filter_all = true
    elsif params[:date] == Time.zone.now.strftime("%Y-%m-%d")
      @filter_today = true
    elsif params[:date] == (Time.zone.now - 1.day).strftime("%Y-%m-%d")  
      @filter_yesterday = true
    end    
    
    @selected_date = params[:date]
    
  end

end
