module Printable
  extend ActiveSupport::Concern

  def initialize
    @qrs = []
    @default_size = 20
  end
    
  def convert_fabrication_orders_to_barcode id
    fo = FabricationOrder.find(id)
    addr = fo.job.address
    apt = fo.job.address2
    fo.rooms.each do |room|
      room.products.each do |product|
        product.product_sections.each do |sect|
          img_size = calc_img_size(sect)
          @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png"), addr, apt, 
                    sect.size, sect.edge_type_a.name, sect.edge_type_b.name, sect.edge_type_c.name, sect.edge_type_d.name,
                    sect.size_type, img_size[0], img_size[1] ]
        end        
      end
    end     
  end
    
  def convert_fabrication_orders_to_qr id
    rooms = FabricationOrder.find(id).rooms
    rooms.each do |room|
      products =  room.products
      products.each do |product|
        sections = product.product_sections
        sections.each do |s|
          @qrs << ["#{s.name}",
            RQRCode::QRCode.new(
            url_for(action: 'update_status', controller: 'product_sections', id: s),
            :size => @default_size,
            :level => :m )
          ]
        end
      end
    end
  end
  
  def convert_room_orders_to_barcode id
    room = Room.find(id)
    addr = room.fabrication_order.job.address
    apt  = room.fabrication_order.job.address2

    room.products.each do |product|
      product.product_sections.each do |sect|
        img_size = calc_img_size(sect)
        @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png"), addr, apt,
                  sect.size, sect.edge_type_a.name, sect.edge_type_b.name, sect.edge_type_c.name, sect.edge_type_d.name,
                  sect.size_type, img_size[0], img_size[1] ]
      end        
    end      
  end  

  def convert_room_orders_to_qr id
    room = Room.find(id)
    products = room.products
    products.each do |product|
      sections = product.product_sections
      sections.each do |s|
        @qrs << ["#{s.name}",
          RQRCode::QRCode.new(
          url_for(action: 'update_status', controller: 'product_sections', id: s),
          :size => @default_size,
          :level => :m )
        ]
      end
    end
  end
  
  def convert_product_orders_to_barcode id
    product = Product.find(id)
    addr = product.room.fabrication_order.job.address
    apt  = product.room.fabrication_order.job.address2

    product.product_sections.each do |sect|
      img_size = calc_img_size(sect)
      @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png"), addr, apt,
                sect.size, sect.edge_type_a.name, sect.edge_type_b.name, sect.edge_type_c.name, sect.edge_type_d.name,
                sect.size_type, img_size[0], img_size[1] ]
    end  
  end  

  def convert_product_orders_to_qr id
    product = Product.find(id)
    sections = product.product_sections
    sections.each do |s|
      @qrs << ["#{s.name}",
        RQRCode::QRCode.new(
        url_for(action: 'update_status', controller: 'product_sections', id: s),
        :size => @default_size,
        :level => :m )
      ]
    end
  end
  
  def convert_section_orders_to_barcode id
    sect = ProductSection.find(id)
    addr = sect.product.room.fabrication_order.job.address
    apt  = sect.product.room.fabrication_order.job.address2
    img_size = calc_img_size(sect)
    @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png"), addr, apt,
              sect.size, sect.edge_type_a.name, sect.edge_type_b.name, sect.edge_type_c.name, sect.edge_type_d.name,
              sect.size_type, img_size[0], img_size[1] ] 
  end  

  def convert_section_orders_to_qr id
    section = ProductSection.find(id)
    @qrs << ["#{section.name}",
      RQRCode::QRCode.new(
      url_for(action: 'update_status', controller: 'product_sections', id: section),
      :size => @default_size,
      :level => :m )
    ]
  end
  
  def convert_choosen_sections_to_barcode ids
    
    sections = ProductSection.where("product_sections.id IN (?)", ids.split(",")).includes(:product => :room).order("rooms.name ASC, products.name ASC, product_sections.name ASC")
    
    sections.each do |sect|
      addr = sect.product.room.fabrication_order.job.address
      apt  = sect.product.room.fabrication_order.job.address2
      img_size = calc_img_size(sect)
      @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png"), addr, apt,
                sect.size, sect.edge_type_a.name, sect.edge_type_b.name, sect.edge_type_c.name, sect.edge_type_d.name,
                sect.size_type, img_size[0], img_size[1] ]
    end  
  end  

  private
    def calc_img_size(sect)
      if sect.size_a.present? && sect.size_b.present?
        if sect.size_a > sect.size_b
          width  = 100
          height = ((sect.size_b.to_f / sect.size_a.to_f ) * 100)
        else
          height  = 100
          width = ((sect.size_a.to_f  / sect.size_b.to_f ) * 100)
        end
      else
        width = 100
        height = 100
      end
      img_size = [width, height]
    end
end
