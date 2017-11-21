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
    
    def self.fix_finished_status
      Product.where("status = ?","FINISHED").each do |pro|
        prod.product_sections.each do |sect|
          sect.update_attribute(:status,"FINISHED")
        end  
      end  
    end  
end
