class LocationsController < ApplicationController
	before_action :require_admin, only: [:index] 
  def index
    @need_libs = ['maps']
    @latest_ids = Location.latest_ids
    ids = @latest_ids.map {|i| i.id }
    @allLocations = Location.where(id: ids)
    @markers = Gmaps4rails.build_markers(@allLocations) do |location, marker|
      title = "#{location.user.try(:first_name)} #{location.user.try(:last_name)}"
      old = (location.updated_at < 1.minutes.ago rescue false)
      marker.lat location.latitude
      marker.lng location.longitude
      marker.title title
      marker.json({
        :user_id => location.user_id, 
        :old => old,
        :created_at => location.created_at.try(:strftime, '%d %B %Y %H:%M'),
        :updated_at => location.updated_at.try(:strftime, '%d %B %Y %H:%M') 
      })
    end
  end
end
