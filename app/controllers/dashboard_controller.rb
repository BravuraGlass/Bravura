class DashboardController < ApplicationController
  before_action :require_admin
  
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
  end    
  
  def status_multiple_update
    if params[:orig_action] == "sections_detail"
      params[:section_detail].each do |key,value|
        ProductSection.find(key.to_i).update_attribute(:status,value) if value != params[:orig_status]
      end  
      msg = "Material statuses were successfully updated"
    elsif params[:orig_action] == "forders_detail"
      params[:forder_detail].each do |key,value|
        FabricationOrder.find(key.to_i).update_attribute(:status,value) if value != params[:orig_status]
      end  
      msg = "Fabrication Order statuses were successfully updated"
    elsif params[:orig_action] == "jobs_detail"
      params[:job_detail].each do |key,value|
        Job.find(key.to_i).update_attribute(:status,value) if value != params[:orig_status]
      end  
      msg = "Job statuses were successfully updated"  
    end
    
    flash[:notice] = msg
    redirect_to dashboard_path
  end  
end
