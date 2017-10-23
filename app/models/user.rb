require 'securerandom'

class User < ApplicationRecord
  authenticates_with_sorcery!
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_presence_of :type_of_user
  validates_uniqueness_of :email
  
  def generate_token
    self.access_token = SecureRandom.uuid
    self.token_expired = Date.today.next_week
    return self.save
  end  

end
