class DashboardController < ApplicationController
  include Referencable
  before_action :require_admin, except: :index
  
  skip_before_action :require_admin, :require_login,:verify_authenticity_token, if: -> { request.format.json? }
  before_action :api_login_status, if: -> { request.format.json? }  
  before_action :require_admin_api, if: -> { request.format.json? } , except: :index
  before_action :set_job_addresses, only: [:index, :sections_detail, :forders_detail, :jobs_detail, :rooms_detail, :products_detail, :detail]
  
  def index
    
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where(@where_syntax).order("product_sections.status ASC").group("product_sections.status").count
    
    @jobs = Job.order("status ASC").where(@where_syntax).group("status").count
    
    @forders = FabricationOrder.joins(:job).where(@where_syntax).order("fabrication_orders.status ASC").group("fabrication_orders.status").count

    @rooms = Room.joins(fabrication_order: :job).where(@where_syntax).group("rooms.status").count

    @products = Product.joins(room: {fabrication_order: :job}).where(@where_syntax).group("products.status").count

    respond_to do |format|
      format.json do
        if @api_user.type_of_user == USER_TYPE[:field_worker]
          data = {materials: @sections}
        else
          data = {materials: @sections, jobs: @jobs, fabrication_orders: @forders, rooms: @rooms, tasks: @products}
        end   
        render json: api_response(:success,nil, data)
      end  
      format.html
    end
  end 
  
  #it is used by API
  def detail
    if params[:category] == "materials"
      sections_detail
    elsif params[:category] == "jobs"
      jobs_detail
    elsif params[:category] == "fabrication_orders"
      forders_detail
    elsif params[:category] == "tasks"
      products_detail
    elsif params[:category] == "rooms"
      rooms_detail      
    end  
        
  end   
  
  def sections_detail
    @sections = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ? AND product_sections.status = ?", true, params[:status]).where(@where_syntax).order("id desc").select("product_sections.*, jobs.address as job_address") 
    @statuses = Status.where(category: Status.categories[:products])
    
    respond_to do |format|
      
      format.json do
        result = {
          material_statuses: @sections.collect {|sect| {
            id: sect.id,
            name: sect.name,
            status: sect.status,
            address: sect.job_address
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end  
  
  def forders_detail
    @forders = FabricationOrder.joins(:job).where("jobs.active =? AND fabrication_orders.status = ?", true, params[:status]).where(@where_syntax).order("id desc") 
    @statuses = Status.where(category: Status.categories[:fabrication_orders])
    
    respond_to do |format|
      
      format.json do
        result = {
          fabrication_order_statuses: @forders.collect {|forder| {
            id: forder.id,
            name: forder.job_id,
            status: forder.status,
            address: forder.address
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end
  
  def jobs_detail
    @jobs = Job.where("active = ? AND status = ?", true, params[:status]).where(@where_syntax).order("id desc")  
    @statuses = Status.where(category: Status.categories[:jobs])
    
    respond_to do |format|
      
      format.json do
        result = {
          job_statuses: @jobs.collect {|job| {
            id: job.id,
            name: job.customer.contact_info,
            status: job.status,
            address: job.address
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end    
  
  def rooms_detail
    @rooms = Room.joins(fabrication_order: :job)
                 .where('rooms.status = ?', params[:status])
                 .where(@where_syntax)
                 .order("rooms.id desc")  
                 .select("rooms.*, jobs.address as job_address") 

    @statuses = Status.where(category: Status.categories[:rooms])

    respond_to do |format|
      
      format.json do
        result = {
          room_statuses: @rooms.collect {|room| {
            id: room.id,
            name: room.name,
            status: room.status,
            address: room.job_address
          }},
          available_statuses: @statuses.collect {|sta| sta.name}
        } 
        render json: api_response(:success,nil, result)
      end  
      format.html
    end
  end

  def products_detail
    @products = Product.joins(room: {fabrication_order: :job})
                       .where(@where_syntax)
                       .where('products.status = ?', params[:status])
                       .order("products.id desc")
                       .select("products.*, jobs.address as job_address") 
                       
    @statuses = Status.where(category: Status.categories[:tasks])

    respond_to do |format|
      
      format.json do
        result = {
          task_statuses: @products.collect {|product| {
            id: product.id,
            name: product.name,
            status: product.status,
            address: product.job_address
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
            psection.update(status: value, audit_user_name: @current_user.try(:full_name) || @api_user.try(:full_name)) 
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


    elsif params[:orig_action] == "rooms_detail" or params[:category] == "room"
      data = params[:room_detail].blank? == false ? params[:room_detail] : params[:new_statuses] 
      unless data.blank?
        data.each do |key,value|
          if value != params[:orig_status]
            theroom = Room.find(key.to_i)
            theroom.update(status: value, audit_user_name: @current_user.try(:full_name) || @api_user.try(:full_name)) 
            result << {id: theroom.id, name: theroom.name, status: theroom.status}
          end   
        end
        msg = "Room statuses were successfully updated"  
      else
        msg = "No single status was updated"
      end

    elsif params[:orig_action] == "products_detail" or params[:category] == "product"
      data = params[:product_detail].blank? == false ? params[:product_detail] : params[:new_statuses] 
      unless data.blank?
        data.each do |key,value|
          if value != params[:orig_status]
            theproduct = Product.find(key.to_i)
            theproduct.update(status: value, audit_user_name: @current_user.try(:full_name) || @api_user.try(:full_name)) 
            result << {id: theproduct.id, name: theproduct.name, type: theproduct.try(:product_type).try(:name), sku: theproduct.sku, price: theproduct.price, room: theproduct.try(:room).try(:name), status: theproduct.status}
          end   
        end
        msg = "Task statuses were successfully updated"  
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
