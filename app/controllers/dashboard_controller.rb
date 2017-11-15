class DashboardController < ApplicationController
  before_action :require_admin
  
  def index
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).order("product_sections.status ASC").group("product_sections.status").count
    
    @jobs = Job.order("status ASC").where("active = ?", true).group("status").count
    
    @forders = FabricationOrder.joins(:job).where("jobs.active = ?", true).order("fabrication_orders.status ASC").group("fabrication_orders.status").count
  end  
  
  def sections_detail
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ? AND product_sections.status = ?", true, params[:status]).order("id desc") 
    @statuses = Status.where(category: Status.categories[:products])
  end  
  
  def forders_detail
    @forders = FabricationOrder.joins(:job).where("jobs.active =? AND fabrication_orders.status = ?", true, params[:status]).order("id desc") 
  end
  
  def jobs_detail
    @jobs = Job.where("active = ? AND status = ?", true, params[:status]).order("id desc")  
  end    
end
