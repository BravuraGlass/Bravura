require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class ProductSectionsController < ApplicationController
  before_action :set_product_section, only: [:barcode, :show, :edit, :update, :destroy,
     :update_status, :edit_section_status]

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

  def edit_section_status
    if @product_section.update(status: params[:new_status])
      redirect_to update_status_path(@product_section), notice: 'Section status updated'
    else
      redirect_to update_status_path(@product_section), error: 'There was an error updating status'
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
    respond_to do |format|
      format.html {render :layout => 'clean'}
    end
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
