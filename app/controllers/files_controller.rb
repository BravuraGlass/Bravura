class FilesController < ApplicationController
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :api_login_status, if: -> { request.format.json? }  
  before_action :set_file, only: [:show, :edit, :update, :destroy]

  # GET /files
  # GET /files.json
  def index
    @files = params[:job_id] ? Picture.where(job_id: params[:job_id]) : Picture.all
  end

  # GET /files/measurements
  # GET /files/measurements.json
  def measurements
    @files = Asset.all
  end

  def new_measurement
    @file = Measurement.new(owner_id: params[:job_id], owner_type: "Job")
  end

  # GET /files/1
  # GET /files/1.json
  def show
  end

  # GET /files/new
  def new
    @file = Picture.new
  end

  # GET /files/1/edit
  def edit
  end

  # POST /files/create_measurement
  # POST /files/create_measurement.json
  def create_measurement
    begin
      @file = Measurement.new(measurement_params.merge({user_id: current_user.id}))
      respond_to do |format|
        if @file.save
          format.html { redirect_to measurements_files_url(job_id: measurement_params[:owner_id]), notice: 'Measurement was successfully created.' }
          format.json { render json: {status: "Ok", message: "Successfully upload file.", id: @file.id}, status: :ok}
        else
          format.html { render :new_measurement }
          format.json { render json: {error_message: @file.errors.full_messages.join("")}, status: :unprocessable_entity }
        end
      end
    rescue => e
      @file = Measurement.new(measurement_params.except(:data))
      @file.errors.add :data, e
      respond_to do |format|
        format.html { render :new_measurement , alert: e}
        format.json { render json: {error_message: @file.errors.full_messages.join("")}, status: :unprocessable_entity }
      end
    end
  end

  # POST /files
  # POST /files.json
  def create
    @file = Picture.new(picture_params.merge({user_id: current_user.id}))
    respond_to do |format|
      if @file.save
        format.html { redirect_to files_url(job_id: picture_params[:job_id]), notice: 'Picture was successfully created.' }
        format.json { render json: {status: "Ok", message: "Successfully upload file.", id: @file.id}, status: :ok}
      else
        format.html { render :new }
        format.json { render json: {error_message: @file.errors.full_messages.join("")}, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /files/1
  # DELETE /files/1.json
  def destroy
    @file = Picture.find(params[:id])
    if @file
      @file.destroy
      respond_to do |format|
        format.html { redirect_to files_url({job_id: @file.job_id}), notice: 'Picture was successfully destroyed.' }
        format.json { render json: {status: "Ok", message: "Successfully delete file."}, status: :ok}
      end
    else
      respond_to do |format|
        format.html { redirect_to measurements_files_url, notice: 'Picture not found.' }
        format.json { render json: {status: "404", message: "Picture not found."}, status: :not_found}
      end
    end
  end

  # DELETE /files/1/destroy_measurement
  # DELETE /files/1/destroy_measurement.json
  def destroy_measurement
    @file = Asset.find(params[:id]) rescue nil
    if @file
      @file.destroy
      respond_to do |format|
        format.html { redirect_to measurements_files_url(job_id: @file.owner_id), notice: 'Measurement was successfully destroyed.' }
        format.json { render json: {status: "Ok", message: "Successfully delete file."}, status: :ok}
      end
    else
      respond_to do |format|
        format.html { redirect_to measurements_files_url, notice: 'Measurement not found.' }
        format.json { render json: {status: "404", message: "Measurement not found."}, status: :not_found}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file
      # @file = File.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:image, :description, :job_id, image:[])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_params
      params.require(:measurement).permit(:data, :description, :owner_id, :owner_type)
    end
end
