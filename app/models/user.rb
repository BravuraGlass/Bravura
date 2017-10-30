require 'securerandom'

class User < ApplicationRecord
  authenticates_with_sorcery!
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_presence_of :type_of_user
  validates_uniqueness_of :email
  has_many :working_logs
  
  def generate_token(host)
    self.access_token = SecureRandom.uuid
    self.token_expired = (Rails.env.to_s == "production" and host.include?("heroku") == false ? Date.today.next_day : Date.today.next_month)
    return self.save
  end  
  
  def self.api_login_status(params)
    rs = User.where("access_token =? AND id=? AND token_expired >= ?", params[:access_token], params[:access_id], Date.today)
    
    rs.size > 0 ? true : false        
  end  
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end  

end
