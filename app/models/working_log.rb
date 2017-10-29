class WorkingLog < ApplicationRecord
  belongs_to :user
  
  def self.submit(data, submit_type = "checkin")
    wlog_hash = {
      user_id: data[:user_id],
      "#{submit_type}_time": Time.now,
      "#{submit_type}_date": Date.today.to_s
    }

    if data[:barcode]
      wlog_hash["#{submit_type}_method".to_sym] = "automatic"
      
      if data[:barcode] == eval("#{submit_type.upcase}_BARCODE") #and data[:longitude] == "-73.932208" and data[:latitude] == "40.618011"
        ## success
        
      else

        wlog = WorkingLog.new(wlog_hash)   
        wlog.errors.add(:base, "invalid, you didn't scan barcode properly or you do not #{submit_type} from office") 
        return wlog 
      end     
    else
      wlog_hash["#{submit_type}_method".to_sym] = "manual"
    end  
    
    if submit_type == "checkin"
      wlog = WorkingLog.where("user_id = ? AND #{submit_type}_date=?", data[:user_id], Date.today.to_s)[0]
    
      if wlog.nil?
        wlog = WorkingLog.create(wlog_hash)
        wlog.get_location
        return wlog
      else  
        wlog.errors.add(:base, "invalid, you can't checkin more than once at the same day")
      end 
    elsif submit_type == "checkout"
      wlog = WorkingLog.where("user_id = ? AND checkin_date=?", data[:user_id], Date.today.to_s)[0]
      
      unless wlog.nil?
        if wlog.checkout_date.blank?
          wlog.update(wlog_hash)
        else
          wlog.errors.add(:base, "invalid, you can't checkout more than once at the same day")
        end
      else
        wlog = WorkingLog.new(wlog_hash)   
        wlog.errors.add(:base, "invalid, you can't checkout without checkin first")
      end      
    end   
    
    return wlog    
    
  end  
  
  def get_location
    if self.location.blank? and self.latitude and self.longitude
      query = Geocoder.search("#{self.latitude},#{self.longitude}").first
      self.update_attribute(:location, query.address)
    end
    return self.location
  end  
  
  def self.checkin(data)
    self.submit(data)
  end  
  
  def self.checkout(data)
    self.submit(data, "checkout")
  end  
end
