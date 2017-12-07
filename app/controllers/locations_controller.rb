class LocationsController < ApplicationController
	before_action :require_admin, only: [:index] 
  def index
  	@need_libs = ['maps']
  	@allLocations = Location.all
    @markers = Gmaps4rails.build_markers(@allLocations) do |location, marker|
      title = "#{location.user.try(:first_name)} #{location.user.try(:last_name)}"
      marker.lat location.latitude
      marker.lng location.longitude
      marker.title title
      marker.json({:user_id => location.user_id})
    end
  end
end
