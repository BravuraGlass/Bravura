class MapController < ApplicationController
  def index
    tasks = []
    jobs = []
    @selected_date = Date.today

    if params['date']
      begin
        @selected_date = Date.parse(params['date'])
      rescue
        @selected_date = Date.today
      end
    end

    if params[:show_tasks]
      @show_tasks = true
      all_tasks = Task.where.not(latitude: nil).where(duedate: @selected_date.beginning_of_day..@selected_date.end_of_day)
      tasks = Gmaps4rails.build_markers(all_tasks) do |task, marker|
        title = "Task: #{task.title} - duedate: #{task.duedate.strftime("%m/%d/%Y") }"
        marker.lat task.latitude
        marker.lng task.longitude
        marker.title title
        marker.json({:type => :task})
      end
    end

    if params[:show_jobs]
      @show_jobs = true
      all_jobs = Job.where.not(latitude: nil).where(active: true).where(appointment: @selected_date.beginning_of_day..@selected_date.end_of_day)
      jobs = Gmaps4rails.build_markers(all_jobs) do |job, marker|
        appointment = job.appointment ? job.appointment.strftime("%m/%d/%Y") : 'not set'
        type = job.confirmed_appointment ? :confirmed_appointment : :job
        title = "Job: #{job.address[0,20]} - appointment: #{appointment}"
        marker.lat job.latitude
        marker.lng job.longitude
        marker.title title
        marker.json({:type => type})
      end
    end

    @markers = tasks + jobs;
  end
end
