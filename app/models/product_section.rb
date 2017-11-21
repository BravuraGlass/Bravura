class ProductSection < ApplicationRecord
    include AuditableModel

    belongs_to :product
    after_update :sync_status

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
    
    private
    def sync_status
      if self.status == 'FINISHED'
        if self.product.product_sections.collect {|sect| sect.status}.uniq == ["FINISHED"]
          Product.where("id = ?", self.product_id).update_all("status='FINISHED'")
        end
      end    
    end  
    
    

=begin    
    def self.fix_finished_status
      Product.where("status = ?","FINISHED").each do |pro|
        prod.product_sections.each do |sect|
          sect.update_attribute(:status,"FINISHED")
        end  
      end  
    end
=end      
end
