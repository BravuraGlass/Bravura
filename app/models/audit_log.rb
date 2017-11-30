class AuditLog < ApplicationRecord
  # all auditable models can have audit logs
  belongs_to :auditable, polymorphic: true
  
  def category
    if self.auditable_type == "Product"
      "Task"
    elsif self.auditable_type == "ProductSection"
      "Material"
    else
      self.auditable_type
    end      
  end  
  
  def item_name
    self.auditable.try(:name)
  end  
end
