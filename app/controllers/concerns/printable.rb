module Printable
  extend ActiveSupport::Concern

  def initialize
    @qrs = []
    @default_size = 20
  end
  
  def convert_fabrication_orders_to_barcode id
    FabricationOrder.find(id).rooms.each do |room|
      room.products.each do |product|
        product.product_sections.each do |sect|
          @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png")]
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
    room.products.each do |product|
      product.product_sections.each do |sect|
        @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png")]
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
    Product.find(id).product_sections.each do |sect|
      @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png")]   
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
    @qrs << [sect.name, barcode_product_section_url(id: sect.id,format: "png")]    
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
end
