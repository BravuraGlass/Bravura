module Referencable
  extend ActiveSupport::Concern

  def set_job_addresses

    @where_syntax     = "jobs.active = true"

    @job_adresses = Job.order("address ASC")
                       .where(@where_syntax)
                       .map{|job|["(#{job.id}) #{job.address}", job.id]}

    if !params[:job_id].blank?
      @where_syntax = "#{@where_syntax} AND jobs.id in (?)", params[:job_id]  
    end


  end
end