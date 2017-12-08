require 'securerandom'

class User < ApplicationRecord
  authenticates_with_sorcery!
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_presence_of :type_of_user
  validates_uniqueness_of :email
  has_many :working_logs
  has_many :locations, -> { order(created_at: :desc) }

  scope :last_locations, -> {
    joins(:locations)
      .where('locations.created_at = (SELECT MAX(locations.created_at) FROM locations WHERE locations.user_id = users.id)')
      .group(["users.id","locations.longitude","locations.latitude"])
    }
  
  TYPE_OF_USERS = ["System Administrator", "Sales Representative", "Field Worker"]
  
  def generate_token(host="")
    self.access_token = SecureRandom.uuid
    self.token_expired = Date.today.next_month
    return self.save
  end  
  
  def self.api_login(params)
    rs = User.where("access_token =? AND id=? AND token_expired >= ?", params[:access_token], params[:access_id], Date.today)
    
    return {status: (rs.size > 0 ? true : false), user: rs[0]}        
  end  
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end  
  
  def admin?
    self.type_of_user == "0" ? true : false
  end  

  def destroy
      raise DisabledDeletionException
  end

  def delete
    self.destroy
  end

=begin  
  def self.admins_always_access
    User.where("type_of_user = ?","0").each do |user|
      user.update_attribute(:always_access, true)
    end  
  end  
=end  

end

class DisabledDeletionException < Exception
  def message
    "This entity is not deleteable"
  end
end
