class FabricationOrder < ApplicationRecord
  include AuditableModel

  belongs_to :job, optional: true
  has_many :rooms, :dependent => :destroy
  has_many :products, :through => :rooms

  accepts_nested_attributes_for :rooms

  # loop through rooms and products to get the list of segments
  def sections
    sections = []
    rooms.each do |room|
      room.products.each do |product|
        product.product_sections.each do |section|
          sections << section
        end
      end
    end
    sections
  end

  def sections_to_json
    sections.to_json
  end

  def sections_status
    ready = 0
    sections.each do |section|
      # a status with order greater than 10 means ready
      status = Status.where(name: section.status, category: Status.categories[:products]).first
      ready += 1 if (status && status.order >= 10) || section.status == 'Ready'
    end
    { total: sections.size, ready: ready, done: sections.size == ready }
  end
end
