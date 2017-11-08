class DashboardController < ApplicationController
  before_action :require_admin
  
  def index
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).order("product_sections.status ASC").group("product_sections.status").count
    
    @jobs = Job.order("status ASC").where("active = ?", true).group("status").count
    
    @forders = FabricationOrder.joins(:job).where("jobs.active = ?", true).order("fabrication_orders.status ASC").group("fabrication_orders.status").count
  end  
  
  def sections_detail
    @sections = ProductSection.where("status = ?", params[:status]).order("id desc") 
  end  
  
  def forder_detail
    
  end
  
  def job_detail
    
  end    
end
