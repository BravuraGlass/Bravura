class DashboardController < ApplicationController
  before_action :require_admin
  
  skip_before_action :require_admin, :require_login,:verify_authenticity_token, if: -> { request.format.json? }
  before_action :api_login_status, if: -> { request.format.json? }  
  before_action :require_admin_api, if: -> { request.format.json? } 
  
  def index
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).order("product_sections.status ASC").group("product_sections.status").count
    
    @jobs = Job.order("status ASC").where("active = ?", true).group("status").count
    
    @forders = FabricationOrder.joins(:job).where("jobs.active = ?", true).order("fabrication_orders.status ASC").group("fabrication_orders.status").count
    
    respond_to do |format|
      format.json { render json: api_response(:success,nil, {materials: @sections, jobs: @jobs, fabrication_orders: @forders})}
      format.html
    end
  end  
  
  def sections_detail
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ? AND product_sections.status = ?", true, params[:status]).order("id desc") 
    @statuses = Status.where(category: Status.categories[:products])
    
    respond_to do |format|
      
      format.json do
        result = {
          material_statuses: @sections.collect {|sect| {
            id: sect.id,
            name: sect.name,
            status: sect.status,
            address: sect.product.room.fabrication_order.title
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end  
  
  def forders_detail
    @forders = FabricationOrder.joins(:job).where("jobs.active =? AND fabrication_orders.status = ?", true, params[:status]).order("id desc") 
    @statuses = Status.where(category: Status.categories[:fabrication_orders])
    
    respond_to do |format|
      
      format.json do
        result = {
          fabrication_order_statuses: @forders.collect {|forder| {
            id: forder.id,
            address: forder.title,
            status: forder.status
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end
  
  def jobs_detail
    @jobs = Job.where("active = ? AND status = ?", true, params[:status]).order("id desc")  
    @statuses = Status.where(category: Status.categories[:jobs])
    
    respond_to do |format|
      
      format.json do
        result = {
          job_statuses: @jobs.collect {|job| {
            id: job.id,
            customer: job.customer.contact_info,
            address: job.address,
            status: job.status
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end    
  
  def status_multiple_update
    result = []
    if params[:orig_action] == "sections_detail" or params[:category] == "material"
      data = params[:section_detail].blank? == false ? params[:section_detail] : params[:new_statuses]
      unless data.blank?
        data.each do |key,value|
          if value != params[:orig_status]
            psection = ProductSection.find(key.to_i)
            psection.update_attribute(:status,value) 
            result << {id: psection.id, name: psection.name, status: psection.status}
          end   
        end  
        msg = "Material statuses were successfully updated"
      else
        msg = "No single status was updated"
      end    
    elsif params[:orig_action] == "forders_detail" or params[:category] == "fabrication_order"
      data = params[:forder_detail].blank? == false ? params[:forder_detail] : params[:new_statuses] 
      unless data.blank?
        data.each do |key,value|
          if value != params[:orig_status]  
            thefo = FabricationOrder.find(key.to_i)
            thefo.update_attribute(:status,value) 
            result << {id: thefo.id, address: thefo.title, status: thefo.status}
          end  
        end
        msg = "Fabrication Order statuses were successfully updated"
      else
        msg = "No single status was updated"
      end      
      
    elsif params[:orig_action] == "jobs_detail" or params[:category] == "job"
      data = params[:job_detail].blank? == false ? params[:job_detail] : params[:new_statuses] 
      unless data.blank?
        data.each do |key,value|
          if value != params[:orig_status]
            thejob = Job.find(key.to_i)
            thejob.update_attribute(:status,value)
            result << {id: thejob.id, customer: thejob.customer.contact_info, status: thejob.status, address: thejob.address}
          end   
        end
        msg = "Job statuses were successfully updated"  
      else
        msg = "No single status was updated"
      end      
      
    end
    
    respond_to do |format|
      result = {
        category: params[:category],
        updated_data: result
      }
      format.json do 
        render json: api_response(:success, msg, result)
      end  
    
      format.html do  
        flash[:notice] = msg
        redirect_to dashboard_path
      end
    end    
  end  
end
