class Notification
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :device_type
  validates :device_type, inclusion: { in: DEVICE_TYPE, message: "Size Type not valid."}, allow_blank: false

end