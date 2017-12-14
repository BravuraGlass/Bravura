class EdgeType < ApplicationRecord
  include AuditableModel

  validates_uniqueness_of :name, uniqueness: true, allow_blank: false
  validates_presence_of :name
end
