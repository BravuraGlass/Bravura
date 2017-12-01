module SearchParameter
  def date_filter params
    if params && params[:date].present?
      @plain_condition << " AND " if @conditions.present?
      @plain_condition << " DATE(created_at) = '#{params[:date]}'"
    end
  end

  def category_filter params
    if params[:category].blank? or params[:category] == "material"
      @conditions[:auditable_type] = "ProductSection"    
      @conditions[:auditable_id] = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).collect {|sect| sect.id}
            
    elsif params[:category] == "task"
      @conditions[:auditable_type] = "Product"
      @conditions[:auditable_id] = Product.joins(:room => {:fabrication_order => :job}).where("jobs.active = ?", true).collect {|prod| prod.id}
      
    elsif params[:category] == "room"
      @conditions[:auditable_type] = params[:category].titleize
      @conditions[:auditable_id] = Room.joins(:fabrication_order => :job).where("jobs.active = ?", true).collect {|room| room.id}
      
    end  
  end

  def user_filter params
    if params && params[:user].present?
      @conditions[:user_name] = params[:user]
    end
  end

  def address_filter params
    if params && params[:address].present?
      fo = FabricationOrder.find_by(job_id: params[:address])
      if fo.product_section_ids && params[:category].blank? or params[:category] == "material"
        @conditions[:auditable_id] = fo.product_section_ids
      elsif fo.product_ids && params[:category] == "task"
        @conditions[:auditable_id] = fo.product_ids
      elsif fo.room_ids && params[:category] == "room" 
        @conditions[:auditable_id] = fo.room_ids
      end
    end
  end
end