require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class ProductSectionsController < ApplicationController
  before_action :set_product_section, only: [:barcode, :show, :edit, :update, :destroy,
     :update_status, :edit_section_status]
  skip_before_action :require_login, only: [:edit_section_status, :update_status], if: -> { request.format.json? }   
  before_action :api_login_status, only: [:update_status,:edit_section_status, :multiple_edit_section_status], if: -> { request.format.json? }   

  def edit
  end

  # PATCH/PUT /product_section/1
  # PATCH/PUT /product_section/1.json
  def update
    respond_to do |format|
      if @product_section.update(product_section_params)
        format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Section was successfully updated.' }
        format.json { render json: @product_section, status: :ok, location: @product_section }
      else
        format.html { render :edit }
        format.json { render json: @product_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_section/1
  # DELETE /product_section/1.json
  def destroy
    @product_section.destroy
    respond_to do |format|
      format.html { redirect_to edit_fabrication_order_path(params[:fabrication_order_id]), notice: 'Section was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def multiple_edit_section_status
    respond_to do |format|
      @statuses = Status.where(:category => Status.categories[:products]).order(:order)
      
      format.json do
        data = []
        ProductSection.where("id IN (?)", params[:ids]).each do |product_section|
          psection = product_section.update(status: params[:new_status])
          product_section.reload
          
          data << {
            id: product_section.id,
            section_name: product_section.name,
            status: product_section.status
          }  
                  
        end
        
        result = {
          status: :success,
          message: nil,
          data: data,
        }
        
        render json: result
        
      end    
    end  
  end  

  def edit_section_status
    respond_to do |format|
      psection = @product_section.update(status: params[:new_status])
      
      format.html do
        if psection
          redirect_to update_status_path(@product_section), notice: 'Section status updated'
        else
          redirect_to update_status_path(@product_section), error: 'There was an error updating status'
        end
      end
      
      format.json do
        @product_section.reload
        
        render json: build_json_product_status(psection,@product_section) 
      end     
    end  
  end
  
  def barcode
    Google::UrlShortener::Base.api_key = "AIzaSyCHSbVfDBDr13syJSeZPwjxOXS8kssI0S4"
      shorturl = Google::UrlShortener.shorten!(url_for(action: 'update_status', controller: 'product_sections', id: @product_section.id))
    
    respond_to do |format|
      
      barcode = Barby::Code128B.new(shorturl)
      
      format.png { send_data barcode.to_png,type: "image/png", disposition: 'inline' }
      format.html {render :layout => 'clean'}
    end  
  end  

  def update_status
    @statuses = Status.where(:category => Status.categories[:products]).order(:order)
    
    respond_to do |format|
      format.html {render :layout => 'clean'}
      format.json do 
        product_statuses = []
        
        @statuses.each do |status|
          product_statuses << {
            id: status.id,
            name: status.name
          }
        end  
        
        data = {
          section_name: @product_section.name,
          status: @product_section.status,
          product_statuses: product_statuses
        }
        
        result = {
          status: :success,
          message: nil,
          data: data,
        }
        render json: result
      end  
    end
  end
  
  protected
  
  def build_json_product_status(psection,product_section)
    if psection    
      data = {
        id: product_section.id,
        section_name: product_section.name,
        status: product_section.status
      }  
      
      result = {
        status: :success,
        message: nil,
        data: data
      }
    else
      result = {
        status: :failed,
        message: "There was an error updating status",
        data: nil
      }
    end
    
    return result
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_section
      @product_section = ProductSection.find(params[:id])
      @statuses ||= Status.where(:category => Status.categories[:products]).order(:order)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_section_params
      params.require(:product_section).permit(:name, :status)
    end
end