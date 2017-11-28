class UtilitiesController < ApplicationController
  before_action :require_admin, only: [:report, :report_detail, :index] 
  
  def data_backup
    if current_user.first_name.downcase.include?("kevin")
      begin
        @thefiles = Dir.entries(Rails.root+"tmp/backup/")
      rescue
        @thefiles = []
      end
    else
      render plain: "you are not authorized to access this page"
    end    
  end  
  
  def download
    send_file "tmp/backup/#{params[:file]}", disposition: 'inline'
  end  
end
