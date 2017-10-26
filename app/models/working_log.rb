class WorkingLog < ApplicationRecord
  belongs_to :user
  
  def self.submit(data, submit_type = "checkin")
    if data[:barcode]
      #automatic checkin
    else
      themethod = "manual"
    end  
    
    wlog_hash = {
      user_id: data[:user_id],
      "#{submit_type}_time": Time.now,
      "#{submit_type}_date": Date.today.to_s,
      "#{submit_type}_method": themethod
    }
    
    if submit_type == "checkin"
      wlog = WorkingLog.where("user_id = ? AND #{submit_type}_date=?", data[:user_id], Date.today.to_s)[0]
    
      if wlog.nil?
        wlog = WorkingLog.create(wlog_hash)
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
  
  def self.checkin(data)
    self.submit(data)
  end  
  
  def self.checkout(data)
    self.submit(data, "checkout")
  end  
end
