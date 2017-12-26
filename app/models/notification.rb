class Notification
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :device_type
  attr_accessor :device_token
  validates :device_type, inclusion: { in: DEVICE_TYPE, message: "Size Type not valid."}, allow_blank: false
  
  def submit(api_user)
    api_user.update_attributes(
      device_type: self.device_type,
      device_token: self.device_token
    )
    return api_user
  end  

end