class EdgeTypesController < ApplicationController
  before_action :require_admin
  before_action :set_edge_type, only: [:show, :edit, :update, :destroy]
  before_action :api_login_status, only: [:available_types]

  def index
    @edge_types = EdgeType.all
  end

  def show
  end

  def new
    @edge_type = EdgeType.new
  end

  def edit
  end

  def available_types
    @edge_types = EdgeType.all
    
    respond_to do |format|
      format.json { render json: api_response(:success, nil, @edge_types)}
    end
  end  

  def create
    @edge_type = EdgeType.new(edge_type_params)

    respond_to do |format|
      if @edge_type.save
        format.html { redirect_to @edge_type, notice: 'Edge type was successfully created.' }
        format.json { render :show, status: :created, location: @edge_type }
      else
        format.html { render :new }
        format.json { render json: @edge_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @edge_type.update(edge_type_params)
        params_redirect = {id: @edge_type.id}
        params_redirect.merge!({scroll: true}) if params[:scroll]
        format.html { redirect_to edge_type_path(params_redirect), notice: 'Edge type was successfully updated.' }
        format.json { render :show, status: :ok, location: @edge_type }
      else
        format.html { render :edit }
        format.json { render json: @edge_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @edge_type.destroy
    respond_to do |format|
      format.html { redirect_to edge_types_url, notice: 'Edge type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_edge_type
      @edge_type = EdgeType.find(params[:id])
    end

    def edge_type_params
      params.require(:edge_type).permit(:name)
    end
end
