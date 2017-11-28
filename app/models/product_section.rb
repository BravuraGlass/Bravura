class ProductSection < ApplicationRecord
    include AuditableModel

    belongs_to :product
    after_update :sync_status
    attr_accessor :audit_user_name

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
      unless self.status_before_last_save == self.status
        AuditLog.create(
          user_name: self.audit_user_name,
          details: "updated material's status from #{self.status_before_last_save} to #{self.status}",
          auditable: self
        )
      end 
      
      old_product_status = self.product.status
      old_room_status = self.product.room.status
      
      if self.status == 'FINISHED'
        if self.product.product_sections.collect {|sect| sect.status}.uniq == ["FINISHED"]
          Product.where("id = ?", self.product_id).update_all("status='FINISHED'")
          unless old_product_status == "FINISHED"
            AuditLog.create(
              user_name: self.audit_user_name,
              details: "updated material's status from #{old_product_status} to FINISHED",
              auditable: self.product
            )
          end  
          
          if self.product.room.products.collect {|prod| prod.status}.uniq == ["FINISHED"]
            Room.where("id = ?", self.product.room_id).update_all("status='FINISHED'")
            unless old_room_status == "FINISHED"
              AuditLog.create(
                user_name: self.audit_user_name,
                details: "updated room's status from #{old_room_status} to FINISHED",
                auditable: self.product.room
              )
            end  
          end  
        end
      elsif self.status != 'FINISHED' && attribute_before_last_save("status") == "FINISHED"
        Product.where("id = ?", self.product_id).update_all("status='Pending'")
        unless old_product_status == "Pending"
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated material's status from #{old_product_status} to Pending",
            auditable: self.product
          )
        end  
        
        unless old_room_status == "Active"
          Room.where("id = ?", self.product.room_id).update_all("status='Active'")
          AuditLog.create(
            user_name: self.audit_user_name,
            details: "updated material's status from #{old_room_status} to Active",
            auditable: self.product.room
          )
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
