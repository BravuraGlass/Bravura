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
  
  def products_group
    arr_products = []
    self.products.select("name").group("products.name").each do |prod|
      sect_count = 0
      max_col = 0
      self.products.where("products.name = ?",prod.name).each do |prod2|    
        ind_count = prod2.product_sections.count  
        sect_count += ind_count
        max_col = ind_count if ind_count > max_col
      end
      arr_products << {:name => prod.name, :sect_count => sect_count, :max_col => max_col}  
    end  
    return arr_products
  end  
  
  def product_detail
    products = []
    data = []
    total_col = 0
    
    self.fabrication_order.rooms.each_with_index do |room, idx|
      rows = [room.name]

      self.products_group.each do |arr_prod|
        room.products.each do |prod|
          if arr_prod[:name] == prod.name
            tru_sect_count = prod.product_sections.count 
            rows += prod.product_sections.collect {|sect| "#{sect.status}-#{sect.product.name}"}
                  
          end    

        end  
             
      end  
      
      data << rows
    end
    
    return data   
  end  
  
end
