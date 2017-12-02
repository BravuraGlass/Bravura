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
      self.submit_time.strftime("%A %B %d, %Y %H:%M:%S")
    else
      nil
    end 
  end
  
  def self.create_report_detail(params)
    
    errors = []
    
    start_time = Time.zone.parse(params[:date].to_s) + params[:start_hour].to_i.hours + params[:start_minute].to_i.minutes + params[:start_second].to_i
    finish_time = Time.zone.parse(params[:date].to_s) + params[:finish_hour].to_i.hours + params[:finish_minute].to_i.minutes + params[:finish_second].to_i  
    
    if finish_time == start_time
      errors << "Start and Finish time can't be same"
    end  
    
    if start_time > finish_time
      errors << "Start time should be less than Finish time"
    end  
    
    unless errors.size > 0
      @existing_wlogs = WorkingLog.where("user_id = ? AND submit_date = ?", params[:user_id], params[:date].to_i)
    
      @existing_wlogs.each do |wlog|
        if wlog.submit_time >= start_time and wlog.submit_time <= finish_time
          errors << "start time and finish time is overlapping with another time on this day"
          break
        end
      end
    end    

    unless errors.size > 0
      WorkingLog.create(
        submit_time: start_time,
        submit_method: "manual",
        user_id: params[:user_id],
        submit_date: params[:date].to_i,
        checkin_or_checkout: "checkin"
      )  
      
      WorkingLog.create(
        submit_time: finish_time,
        submit_method: "manual",
        user_id: params[:user_id],
        submit_date: params[:date].to_i,
        checkin_or_checkout: "checkout"
      )  
    end  
        
    return {errors: errors} 
  end  
  
  def self.update_report_detail(params)
    errors = []
    
    @working_logs = WorkingLog.where("id IN (?) AND user_id = ?",params[:ids].split(","), params[:user_id])
    
    start_time = Time.zone.parse(@working_logs[0].submit_date.to_s) + params[:start_hour].to_i.hours + params[:start_minute].to_i.minutes + params[:start_second].to_i
    finish_time = Time.zone.parse(@working_logs[0].submit_date.to_s) + params[:finish_hour].to_i.hours + params[:finish_minute].to_i.minutes + params[:finish_second].to_i
    
    if finish_time == start_time
      errors << "Start and Finish time can't be same"
    end  
    
    if start_time > finish_time
      errors << "Start time should be less than Finish time"
    end 
    
    unless errors.size > 0
      errors = WorkingLog.overlapping_time(@working_logs, start_time, finish_time)[:errors]
    end  
        
    rs = []
    
    unless errors.size > 0
      if @working_logs.size == 2
        @working_logs[0].update_attribute(:submit_time, start_time)
        @working_logs[1].update_attribute(:submit_time, finish_time)
      elsif @working_logs.size == 1
        if @working_logs[0].checkin_or_checkout == "checkin"
          @working_logs[0].update_attribute(:submit_time, start_time)
          WorkingLog.create(
            submit_time: finish_time,
            submit_method: "manual",
            user_id: params[:user_id],
            submit_date: @working_logs[0].submit_date,
            checkin_or_checkout: "checkout"
          )  
        elsif @working_logs[0].checkin_or_checkout == "checkout"
          @working_logs[0].update_attribute(:submit_time, finish_time)
          WorkingLog.create(
            submit_time: start_time,
            submit_method: "manual",
            user_id: params[:user_id],
            submit_date: @working_logs[0].submit_date,
            checkin_or_checkout: "checkin"
          )    
        end    
      end            
    end
    
    return {errors: errors}  
      
  end
  
  def self.overlapping_time(working_logs, start_time, finish_time)
    user_id = working_logs[0].user_id
    
    if working_logs.size == 1
      prevs = WorkingLog.where("user_id=? AND submit_date=? AND submit_time < ?",user_id, working_logs[0].submit_date, working_logs[0].submit_time).order("submit_time DESC")
    
      nexts = WorkingLog.where("user_id=? AND submit_date=? AND submit_time > ?",user_id, working_logs[0].submit_date, working_logs[0].submit_time).order("submit_time ASC")
    
      prev_time =  prevs.size > 0 ? prevs[0].submit_time : Time.zone.parse(working_logs[0].submit_date.to_s)-1.second
    
      next_time =  nexts.size > 0 ? nexts[0].submit_time : Time.zone.parse(working_logs[0].submit_date.to_s).next_day
    
    elsif working_logs.size == 2
    
      prevs = WorkingLog.where("user_id=? AND submit_date=? AND submit_time < ?",user_id, working_logs[0].submit_date, working_logs[0].submit_time).order("submit_time DESC")
          
      nexts = WorkingLog.where("user_id=? AND submit_date=? AND submit_time > ?",user_id, working_logs[1].submit_date, working_logs[1].submit_time).order("submit_time ASC")
    
      prev_time =  prevs.size > 0 ? prevs[0].submit_time : Time.zone.parse(working_logs[0].submit_date.to_s)-1.second
    
      next_time =  nexts.size > 0 ? nexts[0].submit_time : Time.zone.parse(working_logs[0].submit_date.to_s).next_day

    end
    
    errors = []  
  

    if start_time < prev_time or start_time > next_time
      errors << "start time is overlapping with another time on this day"
    end
    
    if finish_time < prev_time or finish_time > next_time
      errors << "finish time is overlapping with another time on this day"
    end  
      
    return {errors: errors}
  end
    
  protected
  def start_time  
    self.checkin_or_checkout == "checkin" ? self.submit_time : Time.zone.parse(self.submit_date.to_s)
  end
  
  def finish_time  
    self.checkin_or_checkout == "checkout" ? self.submit_time : Time.zone.parse(self.submit_date.to_s)
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
    tempdata =  WorkingLog.where("user_id =? AND submit_date >= ? AND submit_date <= ?", user_id, wstart, wend).order("submit_time ASC")
    
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
          checkin_location: data[idx-1].get_location,
          checkout: data[idx].submit_time.strftime("%H:%M:%S"),
          checkout_location: data[idx].get_location,
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
    
    if rs.size > 0
      users = User.where("id NOT IN (?)", rs.collect {|data| data[:user_id]})
    else
      users = User.all
    end    

    users.each do |user|
      rs << {user_id: user.id, name: user.full_name, duration: 0, status: "manual"}
    end  
    
    return rs
  end 
  
  def self.report_raw(wstart,wend)
    return WorkingLog.where("submit_date >= ? AND submit_date <= ?", wstart, wend).order("user_id ASC, submit_time ASC")
  end   
        
end
