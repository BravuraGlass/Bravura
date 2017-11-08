class DashboardController < ApplicationController
  before_action :require_admin
  
  def index
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).order("product_sections.status ASC").group("product_sections.status").count
    
    @jobs = Job.order("status ASC").where("active = ?", true).group("status").count
    
    @forders = FabricationOrder.includes(:job).where("jobs.active = ?", true).order("fabrication_order.status ASC").group("fabrication_order.status").count
  end  
  
  def section_detail
    @sections = ProductSection.where("name = ?", params[:name]).order("id desc") 
  end  
  
  def forder_detail
    
  end
  
  def job_detail
    
  end    
end
