class Status < ApplicationRecord
  include AuditableModel

  enum category: [:jobs, :products, :fabrication_orders, :tasks, :rooms]

  def detail
    "#{name} - #{category.titleize}"
  end

end
