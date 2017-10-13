class ProductSection < ApplicationRecord
    include AuditableModel

    belongs_to :product

    def as_json(options)
      super(include: {
                        product: {
                          only: [:name, :product_name, :status, :room, :product_index],
                          include: {
                            room: { only: [:name] }
                          }
                        }
                    })
    end
end
