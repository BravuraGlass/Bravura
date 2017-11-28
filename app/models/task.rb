class Task < ApplicationRecord
  include AuditableModel
  validates_presence_of :title, :on => :create

  def self.statuses
    Status.where(:category => Status.categories[:tasks]).order(:order)
  end
end
