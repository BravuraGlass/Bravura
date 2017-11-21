class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy, :update_status]
  
  skip_before_action :require_login,:verify_authenticity_token, only: [:statuses, :available_statuses, :update_status], if: -> { request.format.json? }
  before_action :api_login_status, only: [:statuses, :available_statuses, :update_status], if: -> { request.format.json? }

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)
    @room.fabrication_order_id = params[:fabrication_order_id]

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room.fabrication_order, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { redirect_to @room.fabrication_order, notice: 'There was an error creating the room' }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    
    respond_to do |format|

      if @room.update(room_params)
        format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_status
    @statuses = Status.where(:category => Status.categories[:rooms]).order(:order).collect {|sta| sta.name}
    
    respond_to do |format|
      if params[:status].blank?
        format.json { render json: api_response(:failed,"status can't empty",nil)}
      elsif @statuses.include?(params[:status]) == false  
        format.json { render json: api_response(:failed,"status name is invalid",nil)}
      elsif @room.update_attribute(:status, params[:status])
        result = {id: @room.id, name: @room.name, status: @room.status}
        format.json { render json: api_response(:success,nil,result)}
      else
        format.json { render json: api_response(:failed, @room.errors.full_messages.join(","),nil) }
      end  
    end  
  end  

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def clone
    @room = Room.where("id = ? AND fabrication_order_id = ?", params[:id], params[:fabrication_order_id])[0]
    
    respond_to do |format|
      if @room
        if @room.master_clone
          format.json { render json: Room.last, status: :created } 
        else
          respond_to do |format|
            format.json { render json: "errors", status: :unprocessable_entity }
          end  
        end    
      else
        respond_to do |format|
          format.json { render json: "errors", status: :unprocessable_entity }
        end
      end
    end      
    
  end  
  
  def available_statuses
    @statuses = Status.where(:category => Status.categories[:rooms]).order(:order).collect {|sta| sta.name}
    
    respond_to do |format|
      format.json { render json: api_response(:success, nil, @statuses)}
    end
  end  
  
  def list
    @rooms = FabricationOrder.find(params[:fabrication_order_id]).sorting_rooms
    
    respond_to do |format|
      result = @rooms.collect {|room| {
        id: room.id,
        name: room.name,
        status: room.status  
      }}
      format.json { render json: api_response(:success, nil, result)}
    end
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:name, :description, :master, :room_id, :status)
    end
end
