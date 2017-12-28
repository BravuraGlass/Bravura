class Status < ApplicationRecord
  include AuditableModel

  enum category: [:jobs, :products, :fabrication_orders, :tasks, :rooms]

  def self.products_and_tasks
    statuses = []
    statuses << Status.categories[:products]
    statuses << Status.categories[:tasks]
    statuses
  end

  def name_alias
    case category
    when "products"
      name_with_category
    when "tasks"
      name_with_category
    else
      name
    end
  end

  def detail
    "#{name} - #{category.titleize}"
  end

  def category_alias
    case category
    when "products"
      "Materials"
    else
      category.titleize
    end
  end

  def name_with_category
    "#{category_alias} - #{name}"
  end

end
