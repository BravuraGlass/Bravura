class CustomersController < ApplicationController
  include AuditableController

  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.all
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @need_libs = ['maps']
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    @need_libs = ['maps']
  end

  # GET /customers/1/edit
  def edit
    @need_libs = ['maps']
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render json: @customer, status: :created, location: @customer }
      else
        
        format.html { render :new }
        format.json { render json: @customer.errors.full_messages.join(","), status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        params_redirect = {id: @customer.id}
        params_redirect.merge!({scroll: true}) if params[:scroll]
        format.html { redirect_to customer_path(params_redirect), notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer ||= Customer.find(params[:id])
    end

    # Sets the audit log data
    def set_audit_log_data
      @audit_log.auditable = @customer if @audit_log
    end

    # Saves the previous state of the object that was edited
    def set_previous_audit_log_data
      @previous_object = @customer || Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:contact_firstname, :contact_lastname, :company_name, :email, :email2, :address, :address2, :phone_number, :phone_number2, :fax, :notes)
    end
end
