class Job < ApplicationRecord
  include AuditableModel

  has_many :comments, dependent: :destroy
  has_one :fabrication_order, dependent: :destroy
  has_many :pictures

  belongs_to :customer
  belongs_to :salesman, foreign_key: 'salesman_id', class_name: 'Employee', optional: true
  belongs_to :installer, foreign_key: 'installer_id', class_name: 'Employee', optional: true


  def balance
    price - deposit if price && deposit
  end
  
  def products
    self.fabrication_order.products
  end  
  
  def product_detail
    products = self.products
    
    data = []

    self.fabrication_order.rooms.each do |room|
      rows = []

      products.each do |prod|
        tru = room.products.where("id=?",prod.id)[0]
        unless tru.nil?
          tru.product_sections.each do |sect|
          
            rows << sect.status
          end
        else   
          prod.product_sections.each do |sect|
          
            rows << ""
          end
        end    
      end
          
      data << [room.name] + rows
    end  
    
    return data 
  end  
  
end
