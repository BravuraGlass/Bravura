class Location < ApplicationRecord
	belongs_to :user

  scope :last_user_checkins, -> {
    joins(:user)
      .where('locations.created_at = (SELECT MAX(locations.created_at) FROM locations WHERE locations.user_id = users.id)')
      .where('locations.latitude is not null')
      .where('locations.latitude <> ""')
      .group(["users.first_name","users.last_name","locations.latitude","locations.longitude","locations.created_at"])
    }
end
