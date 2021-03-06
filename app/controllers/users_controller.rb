class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  #skip_before_action :require_login, only: [:index, :new, :create]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    @inactive_users = User.unscoped.where(active: false)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        params_redirect = {}
        params_redirect.merge!({scroll: true}) if params[:scroll]
        format.html { redirect_to users_url(params_redirect), notice: 'User was successfully updated.' }
        format.json { render :index, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully deactivated.' }
      format.json { head :no_content }
    end
  end

  def activate
    @user = User.unscoped.find(params[:id])
    @user.activate
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully activated.' }
      format.json { head :no_content }
    end
  end
  
  def revoke
    if current_user.admin?
      user = User.find(params.permit(:id)[:id])
      if user.id == current_user.id
        flash[:alert] = "failed, you can't revoke access yourself"
        
      else  
        user.update_attributes(password: "br4vur4n3w", token_expired: Date.today.prev_day, access_token: nil, device_type: nil, device_token: nil)
        
        if user.errors.size > 0
          flash[:alert] = user.errors.full_messages.join(",")
        else
          flash[:notice] = "Access for #{user.full_name} was successfully revoked"
        end    
      end  
      redirect_to users_url
    else
      render plain: "you are not authorized to access this page"
    end    
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :first_name, :last_name, :phonenumber, :address, :type_of_user, :always_access)
    end
end
