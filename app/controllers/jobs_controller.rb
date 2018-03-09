class JobsController < ApplicationController

  before_action :set_job, only: [:show, :edit, :update, :destroy, :destroy_image, :add_image, :product_detail, :assign]
  before_action :load_common_data, except: [:index, :assign]
  before_action :set_markers, only: [:show, :edit]
  
  skip_before_action :require_login, :verify_authenticity_token, only: [:all_active_data], if: -> { request.format.json? }   
  before_action :api_login_status, only: [:all_active_data], if: -> { request.format.json? }  
  
  def all_active_data
    respond_to do |format|
      format.json {render json: api_response(:success, nil, Job.all_active_data)}
    end  
  end  
  
  def active_list    
    respond_to do |format|
      format.json do
        data = Job.where("active = true").collect {|job| {id: job.id, name: "(#{job.id}) #{job.address[0...40]}"}}
        render json: api_response(:success,nil, data)
      end  
    end  
  end  

  # GET /jobs
  # GET /jobs.json
  def index
    @show_active = params[:active].eql?('false') ? false : true
    @selected_date = Date.today
    @sorted_users = User.all.sort_by {|usr| usr.last_name.downcase.to_i == 0 ? 1000 : usr.last_name.downcase.to_i }

    if params['filter']
      case params['filter']
      when 'all'
        @filter_all = true
        where = {active: @show_active}
      when 'today'
        @filter_today = true
        where = {active: @show_active, appointment: Date.today.beginning_of_day..Date.today.end_of_day}
      when 'tomorrow'
        @filter_tomorrow = true
        where = {active: @show_active, appointment: Date.tomorrow.beginning_of_day..Date.tomorrow.end_of_day}
      when 'nextweek'
        @filter_nextweek = true
        where = {active: @show_active, appointment: Date.today.next_week..Date.today.next_week.end_of_week}
      when 'date'
        @filter_date = true
        if params['date']
          begin
            @selected_date = Date.parse(params['date'])
          rescue
            @selected_date = Date.today
          end
          whhere = {active: true, appointment: @selected_date.beginning_of_day..@selected_date.end_of_day}
        end
      else
        # default to today
        @filter_today = true
        where = {active: @show_active, appointment: Date.today.beginning_of_day..Date.today.end_of_day}
      end
    else
      # default to all if no filter was set
      @filter_all = true
      where = {active: @show_active, appointment: Date.today.beginning_of_day..Date.today.end_of_day}
    
    end

    plain_where = if params[:address]
      "upper(jobs.address) like upper('%#{params[:address]}%')"
    else
      "1=1"
    end
    
    @jobs = Job.where(where).where(plain_where).joins("LEFT JOIN customers ON customers.id = jobs.customer_id LEFT JOIN fabrication_orders ON fabrication_orders.job_id = jobs.id").select("customers.contact_firstname AS customer_firstname, customers.contact_lastname AS customer_lastname, customers.company_name AS customer_company_name, jobs.*, fabrication_orders.status AS fo_status, fabrication_orders.id AS fo_id")
    # set_markers if @job.id
  end

  # GET /dashboard
  # GET /dashboard.json
  def dashboard
    if params['filter']
      case params['filter']
      when 'all'
        @filter_all = true
        @jobs = Job.where(active: true)
      when 'today'
        @filter_today = true
        @jobs = Job.where(active: true, appointment: Date.today.beginning_of_day..Date.today.end_of_day)
      when 'tomorrow'
        @filter_tomorrow = true
        @jobs = Job.where(active: true, appointment: Date.tomorrow.beginning_of_day..Date.tomorrow.end_of_day  )
      when 'nextweek'
        @filter_nextweek = true
        @jobs = Job.where(active: true, appointment: Date.today.next_week..Date.today.next_week.end_of_week )
      when 'date'
        @filter_date = true
        if params['date']
          begin
            @selected_date = Date.parse(params['date'])
          rescue
            @selected_date = Date.today
          end
          @jobs = Job.where(active: true, appointment: @selected_date.beginning_of_day..@selected_date.end_of_day)
        end
      else
        # default to today
        @filter_today = true
        @jobs = Job.where(active: true, appointment: Date.today.beginning_of_day..Date.today.end_of_day)
      end
    else
      # default to today
      @filter_today = true
      @jobs = Job.where(active: true, appointment: Date.today.beginning_of_day..Date.today.end_of_day)
    end

  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.where(id: params[:id]).joins("LEFT JOIN customers ON customers.id = jobs.customer_id LEFT JOIN fabrication_orders ON fabrication_orders.job_id = jobs.id").select("customers.contact_firstname as customer_firstname, customers.contact_lastname as customer_lastname, customers.company_name as customer_company_name, jobs.*, fabrication_orders.id as fo_id,fabrication_orders.status as fo_status").first
    @prev = @job.prev
    @next = @job.next
    @need_libs = ['maps']
  end

  # GET /jobs/new
  def new
    @job = Job.new
    @need_libs = ['maps']
  end

  # GET /jobs/1/edit
  def edit
    @need_libs = ['maps']
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)
    @job.active = 1
    # set appointmend end date
    if @job.appointment.present?
      if @job.appointment_end.nil?
        @job.appointment_end = nil
      else   
        @job.appointment_end =  @job.appointment.beginning_of_day + ( @job.appointment_end -  @job.appointment_end.beginning_of_day)
     end  
    end
    respond_to do |format|
      if @job.save
        AuditLog.create(ip: request.remote_ip, user_name: @current_user.try(:full_name) || @api_user.try(:full_name), user_agent: request.user_agent, auditable: @job, details: "Newly created data, set status to #{@job.status}")
        
        format.html { redirect_to jobs_path(filter: :all), notice: 'Job was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      params[:job][:audit_user_name] = @current_user.try(:full_name) || @api_user.try(:full_name)
      if @job.update(job_params)
        # set appointmend end date
        if @job.appointment.present?
          if @job.appointment_end.nil?
            @job.appointment_end = nil
          else   
            @job.appointment_end =  @job.appointment.beginning_of_day + ( @job.appointment_end -  @job.appointment_end.beginning_of_day)
          end  
        end
        # upload images
        if job_params[:images]
          job_params[:images].each do |image|
            @job.images << image
          end
        end
    
        @job.save!
        
        params_redirect = {id: params[:redirect_id].nil? ? @job.id : params[:redirect_id]}
        params_redirect.merge!({scroll: true}) if params[:scroll]

        format.html { redirect_to select_job_path(params_redirect), notice: 'Job was successfully updated.' }
        format.json do
          flash[:notice] = "status for #{@job.customer.contact_info} was successfully updated" 
          render json: @job, status: :ok, location: @job
        end  
      else
        format.html { redirect_to select_job_path(params_redirect) }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def assign
      
    @job.update_attribute(:assign_to_id, params[:user_id])
    
    data = {
      id: @job.id,
      full_name: @job.assign_to.try(:full_name)
    }
      
    respond_to do |format|
      format.json do
        render json: data, status: :ok
      end  
    end  
      
  end  

  # POST /jobs/1/image
  def add_image
    picture = Picture.create(picture_params.merge({user_id: current_user.try(:id)}))
    picture.job = @job
    if picture.save
      render json: picture, status: :created, location: picture.image.url
    else
      render json: picture.errors, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/1/image/2
  def destroy_image
    picture = Picture.find(params[:picture_id])
    picture.remove_image!
    picture.destroy!
    respond_to do |format|
      format.html { redirect_to select_job_path(@job), notice: 'Image was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def product_detail
    @selected_status = params[:status]
    @statuses = [["N/A","N/A"],["FINISHED","F"]]
    respond_to do |format|
      format.html {}
    end  
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job ||= Job.find(params[:id])
    end

    # Loads the common required data for all forms
    def load_common_data
    
      @customers ||= Customer.all
      @employees ||= Employee.all
      @server_offset = Time.zone.utc_offset / 3600
      @statuses ||= Status.where(:category => Status.categories[:jobs]).order(:order)

      @status_checklist ||= StatusChecklistItem.all.includes(:status).to_json

    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:customer_id, :price, :priority, :deposit, :status,
              :appointment, :appointment_end, :salesman_id, :installer_id, :duration, :duedate, :paid, :balance,
              :notes, :active, :address, :address2, :latitude, :longitude, :confirmed_appointment, :audit_user_name)
    end

    def picture_params
      params.require(:picture).permit(:image, :user_id)
    end

    # Sets the audit log data
    def set_audit_log_data
      @audit_log.auditable = @job if @audit_log
    end

    # Saves the previous state of the object that was edited
    def set_previous_audit_log_data
      @previous_object = @job || Job.find(params[:id])
    end

    def set_markers
      @markers = Gmaps4rails.build_markers(@job) do |job, marker|
        marker.lat job.latitude
        marker.lng job.longitude
        marker.title job.customer.company_name
        marker.json({:type => :job})
      end
    end

end
