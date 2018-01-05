class Location < ApplicationRecord
	belongs_to :user

  scope :last_user_checkins, -> {
    joins(:user)
      .where('locations.created_at = (SELECT MAX(locations.created_at) FROM locations WHERE locations.user_id = users.id)')
      .where('locations.latitude is not null')
      .where('locations.latitude <> ""')
      .group(["users.first_name","users.last_name","locations.latitude","locations.longitude","locations.created_at","locations.updated_at","users.id"])
    }
  scope :latest_ids, -> {
    select('user_id, MAX(id) as id')
    .where('locations.latitude is not null')
    .where('locations.latitude <> ""')
    .group(:user_id)
  }
	
	def address
		if self.latitude and self.longitude
			begin
				result = Geocoder.search("#{self.latitude},#{self.longitude}").first.try(:address)
			rescue
				result = ""
			end  
		end
		return result
	end  
end
