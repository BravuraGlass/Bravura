class Job < ApplicationRecord
  include AuditableModel

  has_many :comments, dependent: :destroy
  has_one :fabrication_order, dependent: :destroy
  has_many :pictures
  has_many :measurements, -> { where(owner_type: "Job")}, dependent:  :destroy, as:         :owner

  belongs_to :customer
  belongs_to :salesman, foreign_key: 'salesman_id', class_name: 'Employee', optional: true
  belongs_to :installer, foreign_key: 'installer_id', class_name: 'Employee', optional: true
  
  belongs_to :assign_to, class_name: "User", optional: true
  
  attr_accessor :audit_user_name

  scope :active_job, -> { where(active: true) }
  
  after_update :sync_status

  def name
    self.address
  end
  
  def external_name
    "Job"
  end  

  def to_li
    li = "<ul>"
    li << "<li>Address: #{self.address}</li>"
    li << "</ul>" 
    li.html_safe
  end
  
  def self.all_active_data
    result = []
    product_ids = []
    room_ids = []
    fo_ids = []
    
    materials = []
    tasks = []
    rooms = []
    forders = []
    
    select_syntax = "product_sections.*,product_types.name as ptype_name, products.name AS product_name, products.status AS product_status, products.room_id AS room_id, rooms.name AS room_name, rooms.status AS room_status, rooms.fabrication_order_id AS fo_id, fabrication_orders.title AS fo_title, fabrication_orders.status AS fo_status"
    
    ProductSection.joins(:product => [{:room => {:fabrication_order => :job}}, :product_type]).where("jobs.active=?",true).select(select_syntax).each do |section|
      materials << {
        category: "material",
        id: section.id,
        name: section.name,
        status: section.status
      } 
      
      if product_ids.include?(section.product_id) == false
        tasks << {
          category: "task",
          id: section.product_id,
          name: "#{section.product_name} (#{section.ptype_name})",
          status: section.product_status
        }
        product_ids << section.product_id
      end  
  
      if room_ids.include?(section.room_id) == false
        rooms << {
          category: "room",
          id: section.room_id,
          name: section.room_name,
          status: section.room_status,
        }  
        
        room_ids << section.room_id
      end  
      
      if fo_ids.include?(section.fo_id) == false
        forders << {
          category: "address",
          id: section.fo_id,
          name: section.fo_title,
          status: section.fo_status
        }  
        
        fo_ids << section.fo_id
      end  
      
    end   
   
    return materials + tasks + rooms + forders
  end  


  def balance
    price - deposit if price && deposit
  end
  
  def products
    self.fabrication_order.products
  end  
  
  def products_group(level = nil)

    arr_products = []
    self.products.select("name").group("products.name").each do |prod|
      if level.nil? or level == "3"
        sect_count = 0
        max_col = 0
        self.products.where("products.name = ?",prod.name).each do |prod2|    
          ind_count = prod2.product_sections.count  
          sect_count += ind_count
          max_col = ind_count if ind_count > max_col
        end
        arr_products << {:name => prod.name, :sect_count => sect_count, :max_col => max_col} 
      else
        arr_products << {:name => prod.name}
      end     
    end  
    return arr_products
  end   
  
  def product_detail(statuses=[], level = nil)
    if level == "3" or level.nil?
      return product_detail_level_3(statuses=[])
    elsif level == "1"
      return product_detail_level_1
    elsif level == "2"
      return product_detail_level_2  
    end    
  end  
  
  def product_detail_level_1
    rows = []
    self.fabrication_order.rooms.select("CAST(name as SIGNED) AS casted_column, rooms.*").order("casted_column asc, name asc").each do |room|
      
      rows << [
        {content: room.name, prod_count: 0, class_name: room.class.to_s, id: room.id, url: "/fabrication_orders/#{room.id}/audit_room"},
        {content: room.status, prod_count: 1, class_name: room.class.to_s, id: room.id, url: "/fabrication_orders/#{room.id}/audit_room"}
      ]
      
    end  
    
    return rows
  end  
  
  def product_detail_level_2
    rows = []
    self.fabrication_order.rooms.select("CAST(name as SIGNED) AS casted_column, rooms.*").order("casted_column asc, name asc").each do |room|      
      cols = [
        {content: room.name, prod_count: 0, class_name: room.class.to_s, id: room.id, url: "/fabrication_orders/#{room.id}/audit_room"}
      ]
      
      arr_products = self.products_group("2")
      
      arr_products.each_with_index do |arr_prod,idx|
        
        content = ""
        room.products.each do |prod|
          if arr_prod[:name] == prod.name
            content = prod.status
            cols << {content: content, prod_count: idx+2, class_name: prod.class.to_s, id: prod.id}
            break  
          end
        end
        
        if content.empty?
          cols << {content: "", prod_count: idx+2}
        end          
      end    
      
      rows << cols  
    end  
      
    return rows
  end  
    
  def product_detail_level_3(statuses=[])
    products = []
    data = []
    total_col = 0
    
    arr_products = self.products_group
    
    arr_products.each do |arr_prod|
      total_col += arr_prod[:max_col]
    end  

    self.fabrication_order.rooms.select("CAST(name as SIGNED) AS casted_column, rooms.*").order("casted_column asc, name asc").each_with_index do |room, idx|
      rows = [{content: room.name, prod_count: 0, class_name: room.class.to_s, id: room.id, url: "/fabrication_orders/#{room.id}/audit_room"}]
       
      empty_count = 0 
      arr_products.each_with_index do |arr_prod,idx|
        tru_sect_count = 0
        room.products.each do |prod|
          
          if arr_prod[:name] == prod.name
            prod.product_sections.each do |sect|
              #rows << "#{sect.name} #{prod.name}"
              if statuses.nil? or statuses.size == 0 or statuses.include?(sect.status)
                rows << {content: sect.status, prod_count: idx+1, class_name: sect.class.to_s, id: sect.id, url: "/fabrication_orders/#{sect.id}/audit_section"}
              else
                rows << {content: "", prod_count: idx+1}
                empty_count += 1
              end    
              tru_sect_count += 1
            end  
            
          end
          
        end
        
        if arr_prod[:max_col] > tru_sect_count
          1.upto(arr_prod[:max_col] - tru_sect_count) do
            rows << {content: "", prod_count: idx+1}
            empty_count += 1
          end
        end
      end    
      
      unless empty_count == total_col
        data << rows
      end  
    end
    
    return data   
  end

  def next
    self.class.where("id > ?", id).active_job.first
  end

  def prev
    self.class.where("id < ?", id).active_job.last
  end

  def prev_address
    self.class.where.not(
      address: nil, 
      latitude: nil, 
      longitude: nil
    ).order(created_at: :desc).first
  end

  def last_job
    Job.where("active=?",true).order(:id).last
  end

  def last_customer
    last_job.customer
  end
  
  private
  def sync_status
    unless self.status == self.status_before_last_save
      AuditLog.create(
        user_name: self.audit_user_name,
        details: "updated job's status from #{self.status_before_last_save} to #{self.status}",
        auditable: self
      )
    end      
    
    unless self.active == self.active_before_last_save
      AuditLog.create(
        user_name: self.audit_user_name,
        details: "updated job from #{self.active_before_last_save ? "Active" : "Not Active" } to #{self.active ? "Active" : "Not Active"}",
        auditable: self
      )
    end 
  end  
  
end
