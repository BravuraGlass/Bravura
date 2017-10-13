class Room < ApplicationRecord
  include AuditableModel

  belongs_to :fabrication_order

  has_many :products, :dependent => :destroy
end
