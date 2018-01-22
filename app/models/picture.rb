class Picture < ApplicationRecord

  belongs_to :job
  belongs_to :user

  delegate :full_name, to: :user

  mount_base64_uploader :image, ImageUploader

  def data
    image
  end
end
