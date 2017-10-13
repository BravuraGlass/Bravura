class Task < ApplicationRecord
  include AuditableModel
  validates_presence_of :title, :on => :create
end
