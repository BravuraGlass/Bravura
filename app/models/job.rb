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
    
    arr_products = self.products_group
    
    arr_products.each do |arr_prod|
      total_col += arr_prod[:max_col]
    end  
    
    self.fabrication_order.rooms.order("name asc").each_with_index do |room, idx|
      rows = [room.name]

      arr_products.each do |arr_prod|
        tru_sect_count = 0
        room.products.each do |prod|
          
          if arr_prod[:name] == prod.name
            prod.product_sections.each do |sect|
              #rows << "#{sect.name} #{prod.name}"
              rows << sect.status
              tru_sect_count+=1
            end  
            
          end
          
        end
        
        if arr_prod[:max_col] > tru_sect_count
          1.upto(arr_prod[:max_col] - tru_sect_count) do |idx|
            rows << nil
          end
        end
      end    
      
      data << rows
    end
    
    return data   
  end  
  
end
