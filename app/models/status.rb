class Status < ApplicationRecord
  include AuditableModel

  enum category: [:jobs, :products, :fabrication_orders]

  def detail
    "#{name} - #{category.titleize}"
  end

end
