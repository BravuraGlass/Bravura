class MapController < ApplicationController
  def index
    tasks = []
    jobs = []
    workers = []
    @selected_date = Time.zone.now.to_date
    @need_libs = ['maps']
    @show_all = params[:show_all].present?

    if params['date']
      begin
        @selected_date = Date.parse(params['date'])
      rescue
        @selected_date = Time.zone.now.to_date
      end
    end

    task_filter = @show_all ? "1=1" : {duedate: @selected_date.beginning_of_day..@selected_date.end_of_day}
    jobs_filter = @show_all ? "1=1" : {appointment: @selected_date.beginning_of_day..@selected_date.end_of_day}

    if params[:show_tasks]
      @show_tasks = true
      all_tasks = Task.where.not(latitude: nil).where(task_filter)
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
      all_jobs = Job.where.not(latitude: nil).where(active: true).where(jobs_filter)
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

    if params[:show_workers]
      @show_workers = true
      all_workers = Location.last_user_checkins.count
      workers = Gmaps4rails.build_markers(all_workers) do |worker, marker|
        old = (worker[0][4].to_time < 1.minutes.ago rescue false)
        title = "#{worker[0][0]} #{worker[0][1]}-#{old}"
        marker.lat worker[0][2]
        marker.lng worker[0][3]
        marker.title title
        marker.json({:type => :worker})
      end
    end


    @markers = tasks + jobs + workers;
  end
end
