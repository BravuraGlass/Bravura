class StatusChecklistItemsController < ApplicationController
  before_action :set_status_checklist_item, only: [:show, :edit, :update, :destroy]
  before_action :set_common_data, only: [:show, :new, :edit, :index, :create]

  # GET /status_checklist_items
  # GET /status_checklist_items.json
  def index
    @status_checklist_items = StatusChecklistItem.all
  end

  # GET /status_checklist_items/1
  # GET /status_checklist_items/1.json
  def show
  end

  # GET /status_checklist_items/new
  def new
    @status_checklist_item = StatusChecklistItem.new
  end

  # GET /status_checklist_items/1/edit
  def edit
  end

  # POST /status_checklist_items
  # POST /status_checklist_items.json
  def create
    @status_checklist_item = StatusChecklistItem.new(status_checklist_item_params)

    respond_to do |format|
      if @status_checklist_item.save
        format.html { redirect_to @status_checklist_item, notice: 'Status checklist item was successfully created.' }
        format.json { render :show, status: :created, location: @status_checklist_item }
      else
        format.html { render :new }
        format.json { render json: @status_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /status_checklist_items/1
  # PATCH/PUT /status_checklist_items/1.json
  def update
    respond_to do |format|
      if @status_checklist_item.update(status_checklist_item_params)
        format.html { redirect_to @status_checklist_item, notice: 'Status checklist item was successfully updated.' }
        format.json { render :show, status: :ok, location: @status_checklist_item }
      else
        format.html { render :edit }
        format.json { render json: @status_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /status_checklist_items/1
  # DELETE /status_checklist_items/1.json
  def destroy
    @status_checklist_item.destroy
    respond_to do |format|
      format.html { redirect_to status_checklist_items_url, notice: 'Status checklist item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # set common set of data for the views
    def set_common_data
      @statuses = Status.all
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_status_checklist_item
      @status_checklist_item = StatusChecklistItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def status_checklist_item_params
      params.require(:status_checklist_item).permit(:title, :description, :status_id)
    end
end
