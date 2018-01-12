class Location < ApplicationRecord
	belongs_to :user

  scope :last_user_checkins, -> {
    joins(:user)
      .where('locations.created_at = (SELECT MAX(locations.created_at) FROM locations WHERE locations.user_id = users.id)')
      .where('locations.latitude is not null')
      .where('locations.latitude <> ""')
      .group(["users.first_name","users.last_name","locations.latitude","locations.longitude","locations.created_at","locations.updated_at","users.id"])
    }

  scope :last_user_checkins_in, -> (hour=1){
    checkins_in(hour)
      .last_user_checkins
  }

  scope :checkins_in, -> (hour=1){
    where(updated_at: (Time.now-hour.hours)..Time.now)
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
	
	#for development only
	def self.reseed(user1= "", user2 = "", user3 = "", user4 = "")
		user1 = User.first if user1.blank?
		user2 = User.second if user2.blank?
		user3 = User.third if user3.blank?
		user4 = User.fourth if user4.blank?
		
		if Rails.env.to_s == "development"
			time_now = Time.now
			start = (time_now - 3.hours).to_i
      
			Location.destroy_all
			Location.create(user: user1 , latitude: 40.7233, longitude: -74.003)
			Location.create(user: user2, latitude: 40.6937, longitude: -73.988)
			Location.create(user: user3, latitude: 40.6715, longitude: -73.9476)
			Location.create(user: user4, latitude: 40.852, longitude: -74.0753)	
			Location.create(user: user3, latitude: 40.7233, longitude: -74.003, created_at: Time.at(rand(time_now.to_i - start)) + start)
		end	
	end	
end
