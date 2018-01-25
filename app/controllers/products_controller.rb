class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :edit, :update, :destroy, :update_task_status]
  
  skip_before_action :require_login,:verify_authenticity_token, only: [:tasks, :available_task_statuses, :update_task_status], if: -> { request.format.json? }
  before_action :api_login_status, only: [:tasks, :available_task_statuses, :update_task_status], if: -> { request.format.json? }

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    # create room if no room_id was selected
    fabrication_order = FabricationOrder.find(params[:fabrication_order_id])
    if !product_params[:room_id] || product_params[:room_id].blank?
      room = Room.create(name: product_params[:room_name]|| 'New Room')
      room.fabrication_order = fabrication_order
      if room.save
        audit_room = AuditLog.create(ip: request.remote_ip, user_name: current_user.full_name, user_agent: request.user_agent, auditable: room, details: "Newly created data, set status to #{room.status}")
      end
    else
      room = Room.find(product_params[:room_id])
    end

    # create the room
    @product = Product.new
    @product.name = product_params[:name]
    @product.product_type_id = product_params[:product_type_id]
    @product.room = room
    
    product_position = room.products.count + 1

    respond_to do |format|
      if @product.save
        AuditLog.create(ip: request.remote_ip, user_name: current_user.full_name, user_agent: request.user_agent, auditable: @product, details: "Newly created data, set status to #{@product.status}")
        # create each section associated to the product
        sections = 0..product_params[:sections].to_i - 1
        sections.each_with_index do |i, no|
          section_name = "#{fabrication_order.job.id}-#{room.name}-#{product_position}"
          section_name << "-#{no+1}" if sections.to_a.length > 1
          first_status = Status.where(:category => Status.categories[:products]).order(:order).first || ''
          ps = ProductSection.create(name: section_name, product: @product, status: first_status.name, section_index: i + 1)
          if ps
            audit_ps = AuditLog.create(ip: request.remote_ip, user_name: current_user.full_name, user_agent: request.user_agent, auditable: ps, details: "Newly created data, set status to #{ps.status}")
          end
        end
        
        @product.clone_child_data
        # format.html { redirect_to fabrication_order_path(fabrication_order), notice: 'Product was successfully added to the Fabrication Order.' }
        format.json { render json: @product, status: :created, location: fabrication_order }
      else
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def tasks
    @products = Product.where("room_id=?", params[:room_id])
    
    respond_to do |format|
      result = @products.collect {|prod| {id: prod.id, name: prod.name, status: prod.status}}
      
      format.json {render json: api_response(:success, nil, result)}
    end  
  end  
  
  def available_task_statuses
    @statuses = Status.where(:category => Status.categories[:tasks]).order(:order).collect {|sta| sta.name}
    
    respond_to do |format|
      format.json { render json: api_response(:success, nil, @statuses)}
    end
  end  
  
  def update_task_status
    @statuses = Status.where(:category => Status.categories[:tasks]).order(:order).collect {|sta| sta.name}
    
    respond_to do |format|
      if params[:status].blank?
        format.json { render json: api_response(:failed,"status can't empty",nil)}
      elsif @statuses.include?(params[:status]) == false  
        format.json { render json: api_response(:failed,"status name is invalid",nil)}
      elsif @product.update(status: params[:status], audit_user_name: @api_user.full_name)
        result = {id: @product.id, name: @product.name, status: @product.status}
        format.json { render json: api_response(:success,nil,result)}
      else
        format.json { render json: api_response(:failed, @product.errors.full_messages.join(","),nil) }
      end  
    end  
  end  

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      params[:product][:audit_user_name] = current_user.try(:full_name) || @current_user.try(:full_name) || @api_user.try(:full_name)
      if @product.update(product_params)

        params_redirect = {id: params[:fabrication_order_id]}
        params_redirect.merge!({scroll: true}) if params[:scroll]

        format.html { redirect_to edit_fabrication_order_path(params_redirect), notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
      @product_types = ProductType.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:product_type_id, :name, :description,
           :status, :sku, :price, :room_name, :room_id, :sections, :fabrication_order_id, :audit_user_name)
    end

    # Sets the audit log data
    def set_audit_log_data
      @audit_log.auditable = @product if @audit_log
    end

    # Saves the previous state of the object that was edited
    def set_previous_audit_log_data
      @previous_object = @product || Product.find_by_id(params[:id])
    end

    def auditable_attributes_to_ignore
      Product.column_names - ["status"]
    end
end
