include Printable
class FabricationOrdersController < ApplicationController
  before_action :set_fabrication_order, only: [:show, :edit, :update, :destroy]
  before_action :load_common_data, except: [:addresses]
  
  skip_before_action :require_login, only: [:addresses], if: -> { request.format.json? }
  before_action :api_login_status, only: [:addresses], if: -> { request.format.json? }
  
  require 'rqrcode'

  # GET /fabrication_orders
  # GET /fabrication_orders.json
  def index
    # list only fabrications orders of active jobs
    @fabrication_orders = FabricationOrder.includes(:job).where(jobs: { active: true })
  end

  # GET /fabrication_orders/1
  # GET /fabrication_orders/1.json
  def show
  end

  # GET /fabrication_orders/new
  def new
    @fabrication_order = FabricationOrder.new
  end

  # GET /fabrication_orders/1/edit
  def edit
  end

  # POST /fabrication_orders
  # POST /fabrication_orders.json
  def create
    @fabrication_order = FabricationOrder.new

    # find the related job
    job = Job.find(params[:job_id])
    if (job)
      @fabrication_order.job = job
      @fabrication_order.title = job.address
      @fabrication_order.description = "Fabrication order for Job on #{job.address}"
      @fabrication_order.status = @statuses.first.name
    end
    respond_to do |format|
      if @fabrication_order.save
        format.html { redirect_to edit_fabrication_order_path(@fabrication_order), notice: 'Fabrication order was successfully created.' }
        format.json { render :show, status: :created, location: @fabrication_order }
      else
        format.html { render :new }
        format.json { render json: @fabrication_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fabrication_orders/1
  # PATCH/PUT /fabrication_orders/1.json
  def update
    respond_to do |format|
      if @fabrication_order.update(fabrication_order_params)
        format.html { redirect_to edit_fabrication_order_path(@fabrication_order), notice: 'Fabrication order was successfully updated.' }
        format.json { render :show, status: :ok, location: @fabrication_order }
      else
        format.html { render :edit }
        format.json { render json: @fabrication_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fabrication_orders/1
  # DELETE /fabrication_orders/1.json
  def destroy
    @fabrication_order.destroy
    respond_to do |format|
      format.html { redirect_to fabrication_orders_url, notice: 'Fabrication order was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def f_orders_barcode
    convert_fabrication_orders_to_barcode params[:id]
    respond_to do |format|
      format.html  { render template: 'fabrication_orders/barcodes', layout: false }
    end
  end
  
  def r_orders_barcode
    convert_room_orders_to_barcode params[:id]
    respond_to do |format|
      format.html  { render template: 'fabrication_orders/barcodes', layout: false }
    end    
  end  
  
  def p_orders_barcode
    convert_product_orders_to_barcode params[:id]
    respond_to do |format|
      format.html  { render template: 'fabrication_orders/barcodes', layout: false }
    end
  end
  
  def s_orders_barcode
    convert_section_orders_to_barcode params[:id]
    respond_to do |format|
      format.html  { render template: 'fabrication_orders/barcodes', layout: false }
    end
  end

  def f_orders_qr
    render plain: "QR feature lo longer be used" and return
    
    convert_fabrication_orders_to_qr params[:id]
    respond_to do |format|
      format.pdf  { render template: 'fabrication_orders/qr_codes', pdf: 'QRCODES'}
      format.html  { render template: 'fabrication_orders/qr_codes', layout: false }
    end
  end
  
  def r_orders_qr
    render plain: "QR feature lo longer be used" and return
    
    convert_room_orders_to_qr params[:id]
    respond_to do |format|
      format.pdf  { render template: 'fabrication_orders/qr_codes', pdf: 'QRCODES'}
      format.html  { render template: 'fabrication_orders/qr_codes', layout: false }
    end
  end

  def p_orders_qr
    render plain: "QR feature lo longer be used" and return
    
    convert_product_orders_to_qr params[:id]
    respond_to do |format|
      format.pdf  { render template: 'fabrication_orders/qr_codes', pdf: 'QRCODES'}
      format.html  { render template: 'fabrication_orders/qr_codes', layout: false }
    end
  end

  def s_orders_qr
    render plain: "QR feature lo longer be used" and return
    
    convert_section_orders_to_qr params[:id]
    respond_to do |format|
      format.pdf  { render template: 'fabrication_orders/qr_codes', pdf: 'QRCODES'}
      format.html  { render template: 'fabrication_orders/qr_codes', layout: false }
    end
  end
  
  def addresses
    @fabrication_orders = FabricationOrder.joins(:job).where("jobs.active = ?", true)
    
    respond_to do |format|
      result = @fabrication_orders.collect {|fo| {id: fo.id, address: fo.title}}
      format.json {render json: api_response(:success, nil, result)}
    end  
  end  

  private
    # Loads the common required data for all forms
    def load_common_data
      @statuses ||= Status.where(:category => Status.categories[:fabrication_orders]).order(:order)
      @product_statuses ||= Status.where(:category => Status.categories[:products]).order(:order)
      @room_statuses ||= Status.where(:category => Status.categories[:rooms]).order(:order)
      @task_statuses ||= Status.where(:category => Status.categories[:tasks]).order(:order)
      @product_types = ProductType.all
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_fabrication_order
      @fabrication_order = FabricationOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fabrication_order_params
      params.require(:fabrication_order).permit(:title, :description, :status, :job_id)
    end
end
