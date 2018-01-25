module SearchParameter
  def date_filter params
    if params && params[:date].present?
      @plain_condition << " AND " if @conditions.present?
      @plain_condition << " DATE(created_at) = '#{params[:date]}'"
    end
  end
  
  def status_filter params
    if params && params[:status].present?
      if params[:status].include?(',')
        category = params[:status].split(',').last
        puts "::::#{category}:::"
        category_filter({category: category}) if category.present?
      else
        @plain_condition << " AND " if @conditions.present? or @plain_condition.present?
        @plain_condition << " details LIKE '%to #{params[:status]}%'"
      end
    end  
  end 

  def set_default_category params
    if @conditions[:auditable_type].blank?
      @conditions[:auditable_type] = ["Product","ProductSection","Room","Job"]
    end

    if params[:category].blank?
      @plain_condition << " AND " if @plain_condition.present?
      product_ids = Product.joins(:room => {:fabrication_order => :job}).where("jobs.active = ?", true).collect {|sect| sect.id}
      section_ids = ProductSection.joins(:product => {:room => {:fabrication_order => :job}}).where("jobs.active = ?", true).collect {|sect| sect.id}
      room_ids = Room.joins(:fabrication_order => :job).where("jobs.active = ?", true).collect {|room| room.id}
      job_ids = Job.where("active = ?", true).collect {|job| job.id}
      @plain_condition << " ( "
      if product_ids.present?
        @plain_condition << " (auditable_type = 'Product' and auditable_id in (#{product_ids.join(',')})) or"
      end
      if section_ids.present?
        @plain_condition << " (auditable_type = 'ProductSection' and auditable_id in (#{section_ids.join(',')})) or"
      end
      if room_ids.present?
        @plain_condition << " (auditable_type = 'Room' and auditable_id in (#{room_ids.join(',')})) or"
      end
      if job_ids.present?
        @plain_condition << " (auditable_type = 'Job' and auditable_id in (#{job_ids.join(',')}))"
      end
      @plain_condition << " ) "
    end
  end

  def set_auditable_id params
    @plain_condition << " AND " if @plain_condition.present?
    @plain_condition << " auditable_id is not null"
  end

  def category_filter params
    puts "::::::::#{params[:category]}:::::::::::::"
    if params[:category] == "task" 
      @conditions[:auditable_type] = ["Product"]
      @conditions[:auditable_id] = Product.joins(:room => {:fabrication_order => :job})
                                          .where("jobs.active = ?", true).collect {|sect| sect.id}
    elsif params[:category] == "material"
      @conditions[:auditable_type] = ["ProductSection"]
      @conditions[:auditable_id] = ProductSection.joins(:product => {:room => {:fabrication_order => :job}})
                                                 .where("jobs.active = ?", true)
                                                 .collect {|sect| sect.id}
    elsif params[:category] == "room"
      @conditions[:auditable_type] = params[:category].titleize
      @conditions[:auditable_id] = Room.joins(:fabrication_order => :job).where("jobs.active = ?", true).collect {|room| room.id}
      
    elsif params[:category] == "job"  
      @conditions[:auditable_type] = params[:category].titleize
      @conditions[:auditable_id] = Job.where("active = ?", true).collect {|job| job.id}
    end  
  end

  def user_filter params
    if params && params[:user].present?
      @conditions[:user_name] = params[:user]
    end
  end

  def address_filter params
    if params && params[:address].present?
      job = Job.find(params[:address])
      fo = job.fabrication_order
      if fo.try(:product_section_ids) && (params[:category].blank? or params[:category] == "material")
        @conditions[:auditable_id] = fo.product_section_ids
      elsif fo.try(:product_ids) && params[:category] == "task"
        @conditions[:auditable_id] = fo.product_ids
      elsif fo.try(:room_ids) && params[:category] == "room" 
        @conditions[:auditable_id] = fo.room_ids
      elsif job.id && params[:category] == "job" 
        @conditions[:auditable_id] = [job.id]  
      end
    end
  end
   
end