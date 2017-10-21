class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

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
      room.save
    else
      room = Room.find(product_params[:room_id])
    end

    # create the room
    @product = Product.new
    @product.name = product_params[:name]
    @product.product_type_id = product_params[:product_type_id]
    @product.room = room

    respond_to do |format|
      if @product.save
        # create each section associated to the product
        sections = 0..product_params[:sections].to_i - 1
        abc = ("A".."Z").to_a
        sections.each do |i|
          section_name = "#{fabrication_order.job.id}-#{room.name}-#{@product.product_index}#{abc[i]}"
          first_status = Status.where(:category => Status.categories[:products]).order(:order).first || ''
          ProductSection.create(name: section_name, product: @product, status: first_status.name, section_index: i + 1)
        end
        
        @product.clone_child_data
        # format.html { redirect_to fabrication_order_path(fabrication_order), notice: 'Product was successfully added to the Fabrication Order.' }
        format.json { render json: @product, status: :created, location: fabrication_order }
      else
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Product was successfully updated.' }
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
           :status, :sku, :price, :room_name, :room_id, :sections, :fabrication_order_id)
    end
end
