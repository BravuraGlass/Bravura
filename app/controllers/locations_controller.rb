class LocationsController < ApplicationController
	before_action :require_admin, only: [:index] 
  def index
    @show_workers = true
    @workers = []
    @need_libs = ['maps']
    @latest_ids = Location.latest_ids
    ids = @latest_ids.map {|i| i.id }

    # get all checkin in 6 hours ago
    @allLocations = Location.checkins_in(6).where(id: ids)
    user_ids = @allLocations.map(&:user_id)
		
		all_workers = Location.last_user_checkins_in(6).count
		@workers = all_workers.map{|x,y| ["#{x[0]} #{x[1]}",x[6].to_s]} rescue []
		
    #@workers = User.where(id: user_ids).map{|x| [x.try(:full_name), x.try(:id)]} rescue []
    if params[:show_worker].present?
      exclude_workers = params[:show_worker]
    else
      if @allLocations.present?
        redirect_to locations_index_path(params.as_json.merge({show_worker: @workers.map{|x,y|y}}))
        return
      end
    end
    @markers = Gmaps4rails.build_markers(@allLocations) do |location, marker|
      next unless exclude_workers.include?(location.user_id.to_s)
      if location.updated_at > 6.hours.ago
        title = "#{location.user.try(:first_name)} #{location.user.try(:last_name)}"
        old = (location.updated_at < 1.minutes.ago rescue false)
        marker.lat location.latitude
        marker.lng location.longitude
        marker.title title
        marker.json({
          :user_id => location.user_id, 
          :old => old,
          :created_at => location.created_at.try(:strftime, '%d %B %Y %H:%M'),
          :updated_at => location.updated_at,
          :updated_at_text => location.updated_at.try(:strftime, '%d %B %Y %H:%M') 
        })
      end
    end
  end
end
