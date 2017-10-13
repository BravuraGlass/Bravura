class Picture < ApplicationRecord

  belongs_to :job

  mount_uploader :image, ImageUploader

end
