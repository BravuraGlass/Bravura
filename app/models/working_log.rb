class WorkingLog < ApplicationRecord
  belongs_to :user
  
  def self.submit(data, checkin_or_checkout = "checkin")
    wlog_hash = {
      user_id: data[:user_id],
      submit_time: Time.now,
      submit_date: Time.zone.now.to_date.to_s.gsub("-","").to_i,
      latitude: data[:latitude],
      longitude: data[:longitude],
      checkin_or_checkout: checkin_or_checkout
    }

    if data[:barcode]
      wlog_hash[:submit_method] = "automatic"
      
      if data[:barcode] == eval("#{checkin_or_checkout.upcase}_BARCODE") #and data[:longitude] == "-73.932208" and data[:latitude] == "40.618011"
        ## success
        
      else
        wlog = WorkingLog.new(wlog_hash)   
        wlog.errors.add(:base, "invalid, you didn't scan barcode properly or you do not #{checkin_or_checkout} from office") 
        return wlog 
      end     
    else
      wlog_hash[:submit_method] = "manual"
    end  
    
    wlog = WorkingLog.create(wlog_hash)
    wlog.get_location
    
    return wlog    
    
  end  
  
  def get_location
    if self.location.blank? and self.latitude and self.longitude
      begin
        query = Geocoder.search("#{self.latitude},#{self.longitude}").first
        self.update_attribute(:location, query.try(:address))
      rescue
      end  
    end
    return self.location
  end  
  
  def self.checkin(data)
    self.submit(data)
  end  
  
  def self.checkout(data)
    self.submit(data, "checkout")
  end 
  
  def readable_date
    unless self.submit_time.blank?
      self.submit_time.strftime("%A %B %d, %Y")
    else
      nil
    end  
  end
  
  def readable_time
    unless self.submit_time.blank?
      self.submit_time.strftime("%A %B %d, %Y %H:%M:%S EDT")
    else
      nil
    end 
  end  
  
  def self.generate_submit_date
    self.all.each do |wlog|
      if wlog.submit_date.blank?
        wlog.update_attribute(:submit_date, wlog.submit_time.to_date.to_s.gsub("-","").to_i)
      end  
    end   
  end  
  
  def self.report(wstart,wend)
    
    data = self.report_raw(wstart,wend)
    rs = []
    
    row = 0
    duration = 0
    newrow = true
    
    data.each_with_index do |wlog,idx|
      if idx > 0
        if newrow == false
          if data[idx].submit_date == data[idx-1].submit_date 
            if data[idx].checkin_or_checkout == "checkout" and data[idx-1].checkin_or_checkout == "checkin"
              subs = data[idx].submit_time - data[idx-1].submit_time
              duration += subs
            end  
          end  
        end  
        
        rs[row] = {name: wlog.user.full_name, duration: duration} 
        
        if data[idx].user_id != data[idx+1].try(:user_id)      
          duration = 0
          row+=1
          newrow = true
        else
          newrow = false   
        end
      else
        rs[row] = {name: wlog.user.full_name, duration: duration}     
        newrow = false
      end      
    end  
    
    return rs
  end 
  
  def self.report_raw(wstart,wend)
    return WorkingLog.where("submit_date >= ? AND submit_date <= ?", wstart, wend).order("user_id ASC, submit_date ASC")
  end   
        
end
