class SpecialArray < Array

  def [](i)
    if i >= 0
      return super(i)
    else   
      return nil
    end  
  end  

end

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
  
  def self.update_report_detail(params)
    
    Hi. I checked some of the screenshots that you are working on. It seems to me that you're making more complicated than it needs to be. Can it be made easier where I go to that person's time and just edited
    byebug
  end
  
  protected
  def start_time  
    self.checkin_or_checkout == "checkin" ? self.submit_time : Time.parse(self.submit_date.to_s)
  end
  
  def finish_time  
    self.checkin_or_checkout == "checkout" ? self.submit_time : Time.parse(self.submit_date.to_s)
  end
  
  public
  def start_hour
    self.start_time.strftime("%H").to_i
  end
  
  def start_minute
    self.start_time.strftime("%M").to_i
  end
  
  def start_second
    self.start_time.strftime("%S").to_i
  end      
  
  def finish_hour
    self.finish_time.strftime("%H").to_i
  end
  
  def finish_minute
    self.finish_time.strftime("%M").to_i
  end
  
  def finish_second
    self.finish_time.strftime("%S").to_i
  end   
  
  def self.generate_submit_date
    self.all.each do |wlog|
      if wlog.submit_date.blank?
        wlog.update_attribute(:submit_date, wlog.submit_time.to_date.to_s.gsub("-","").to_i)
      end  
    end   
  end  
  
  def self.report_detail(user_id,wstart,wend)
    tempdata =  WorkingLog.where("user_id =? AND submit_date >= ? AND submit_date <= ?", user_id, wstart, wend).order("submit_date ASC")
    
    data = SpecialArray.new
    
    tempdata.each do |tdata|
      data << tdata
    end  
      
    rs = SpecialArray.new
    
    row = 0
    duration = 0
    
    data.each_with_index do |wlog,idx|
      if data[idx].checkin_or_checkout == "checkout" and data[idx-1].try(:checkin_or_checkout) == "checkin" and data[idx].submit_date == data[idx-1].try(:submit_date) and idx > 0
        
        duration = data[idx].submit_time - data[idx-1].submit_time
              
        rs[row] = {
          ids: "#{wlog.id},#{data[idx-1].id}",
          user_id: wlog.user_id, 
          name: wlog.user.full_name, 
          duration: duration, 
          date: wlog.readable_date, 
          checkin: data[idx-1].submit_time.strftime("%H:%M:%S"), 
          checkout: data[idx].submit_time.strftime("%H:%M:%S"),
          checkin_method: data[idx-1].submit_method,
          checkout_method: data[idx].submit_method
        }
               
        row+=1  
      elsif (data[idx].checkin_or_checkout == "checkin" and data[idx+1].try(:checkin_or_checkout) != "checkout") or (data[idx].checkin_or_checkout == "checkin" and data[idx].submit_date != data[idx+1].submit_date)
          
        rs[row] = {
          ids: wlog.id.to_s, 
          user_id: wlog.user_id, 
          name: wlog.user.full_name,
          duration: 0, 
          date: wlog.readable_date, 
          checkin: data[idx].submit_time.strftime("%H:%M:%S"), 
          checkout: nil,
          checkin_method: data[idx].submit_method,
          checkout_method: nil
        }
          
        row+=1    
      elsif (data[idx].checkin_or_checkout == "checkout" and data[idx-1].try(:checkin_or_checkout) != "checkin") or (data[idx].checkin_or_checkout == "checkout" and data[idx].submit_date != data[idx-1].submit_date)       
        rs[row] = {
          ids: wlog.id.to_s,
          user_id: wlog.user_id, 
          name: wlog.user.full_name, 
          duration: 0, 
          date: wlog.readable_date, 
          checkin: nil, 
          checkout: data[idx].submit_time.strftime("%H:%M:%S"),
          checkin_method: nil,
          checkout_method: data[idx].submit_method
        }
          
        row+=1          
      end       
    end  
    
    return rs
      
  end  
  
  def self.report(wstart,wend)
    
    data = self.report_raw(wstart,wend)
    rs = []
    
    row = 0
    duration = 0
    newrow = true
    status = "automatic"
    
    data.each_with_index do |wlog,idx|
      if idx > 0
        if newrow == false
          if data[idx].submit_date == data[idx-1].submit_date 
            if data[idx].checkin_or_checkout == "checkout" and data[idx-1].checkin_or_checkout == "checkin"
              subs = data[idx].submit_time - data[idx-1].submit_time
              duration += subs
              status = "manual" if data[idx].submit_method == "manual" or data[idx-1].submit_method == "manual"
            end  
          end  
        end  
        
        rs[row] = {user_id: wlog.user_id, name: wlog.user.full_name, duration: duration, status: status} 
        
        if data[idx].user_id != data[idx+1].try(:user_id)      
          status = "automatic"
          duration = 0
          row+=1
          newrow = true
        else
          newrow = false   
        end
      else
        rs[row] = {user_id: wlog.user_id, name: wlog.user.full_name, duration: duration, status: status}     
        newrow = false
      end          
    end  
    
    return rs
  end 
  
  def self.report_raw(wstart,wend)
    return WorkingLog.where("submit_date >= ? AND submit_date <= ?", wstart, wend).order("user_id ASC, submit_date ASC")
  end   
        
end
