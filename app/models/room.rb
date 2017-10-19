class Room < ApplicationRecord
  include AuditableModel

  belongs_to :fabrication_order

  has_many :products, :dependent => :destroy
  belongs_to :room, class_name: "Room"
  has_many :room, class_name: "Room"
  
  validates :master, uniqueness: true, allow_blank: true
end
