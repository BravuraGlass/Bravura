require 'securerandom'

class User < ApplicationRecord
  authenticates_with_sorcery!
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_presence_of :type_of_user
  validates_uniqueness_of :email
  has_many :working_logs
  has_many :locations, -> { order(created_at: :desc) }
  default_scope { where(active: true) }

  scope :last_locations, -> {
    joins(:locations)
      .where('locations.created_at = (SELECT MAX(locations.created_at) FROM locations WHERE locations.user_id = users.id)')
      .group(["users.id","locations.longitude","locations.latitude"])
    }
  
  TYPE_OF_USERS = ["System Administrator", "Sales Representative", "Field Worker"]
  
  def generate_token(host="")
    self.access_token = SecureRandom.uuid
    self.token_expired = Date.today.next_month
    return self.save
  end  
  
  def self.api_login(params)
    rs = User.where("access_token =? AND id=? AND token_expired >= ?", params[:access_token], params[:access_id], Date.today)
    
    return {status: (rs.size > 0 ? true : false), user: rs[0]}        
  end  

  # clock in
  def checkin_status
    last_log_today = self.working_logs.where("submit_date=?", Time.zone.now.strftime("%Y%m%d"))
                         .order("submit_time DESC")[0]
    last_log_today.blank? ? false : last_log_today.checkin_or_checkout?
  end
  
  def current_week_log
    data = {}
    
    #set_time = (Time.zone.now-3.days).strftime("%Y%m%d")
    set_time = Time.zone.now.strftime("%Y%m%d")
    
    start_time = Date.today.beginning_of_week(:sunday)
    end_time = start_time + 6.day
    
    start_time = start_time.strftime("%Y%m%d").to_i
    end_time = end_time.strftime("%Y%m%d").to_i
      
    cw_logs = WorkingLog.where("submit_date >= ? AND submit_date <= ? AND user_id = ?", start_time, end_time, self.id).order("submit_time DESC")
    
    result = []
    
    start_time.upto(end_time) do |thetime|
      today_logs = cw_logs.select {|thelog| thelog.submit_date == thetime}
      
      data = {}
      
      data[:checkin_time] = nil
      data[:checkout_time] = nil
      data[:checkin_method] = nil
      data[:checkout_method] = nil
      data[:date] = Time.strptime(thetime.to_s, "%Y%m%d").strftime("%a %Y/%m/%d")
      
      if today_logs.size == 2
        data[:checkout_time] = today_logs[0].readable_hours
        data[:checkin_time] = today_logs[1].readable_hours
        
        data[:checkout_method] = today_logs[0].submit_method
        data[:checkin_method] = today_logs[1].submit_method
      elsif today_logs.size == 1
        if today_logs[0].checkin_or_checkout == "checkin"   
          data[:checkin_time] = today_logs[0].readable_hours
          data[:checkin_method] = today_logs[0].submit_method
        elsif today_logs[0].checkin_or_checkout == "checkout"
          data[:checkout_time] = today_logs[0].readable_hours
          data[:checkout_method] = today_logs[0].submit_method
        end    
      end  
        
      result << data  
    end  
    
    return result
  end  
  
  def today_working_log
    data = {}
    
    #set_time = (Time.zone.now-3.days).strftime("%Y%m%d")
    set_time = Time.zone.now.strftime("%Y%m%d")
    
    today_logs = self.working_logs.where("submit_date=?", set_time).order("submit_time DESC")
    last_log_today = today_logs[0]
    
    data[:status] = last_log_today.blank? ? "checkout" : last_log_today.checkin_or_checkout
    data[:checkin_time] = nil
    data[:checkout_time] = nil
    data[:user_id] = self.id
    data[:user_name] = self.full_name
    
    if today_logs.size == 2
      data[:checkout_time] = today_logs[0].readable_hours
      data[:checkin_time] = today_logs[1].readable_hours
    elsif today_logs.size == 1
      if today_logs[0].checkin_or_checkout == "checkin"   
        data[:checkin_time] = today_logs[0].readable_hours
      elsif today_logs[0].checkin_or_checkout == "checkout"
        data[:checkout_time] = today_logs[0].readable_hours
      end    
    end  
    
    return data
  end  
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end  
  
  def admin?
    self.type_of_user == "0" ? true : false
  end  

  def non_worker?
    ( self.type_of_user == "0" || self.type_of_user == "1" )? true : false
  end  

  def destroy
    if self.active?
      self.active = false
      self.save!
    else 
      raise FailedDeactivationException
    end
  end

  def activate
    unless self.active?
      self.active = true
      self.save!
    else 
      raise FailedActivationException
    end
  end

  def delete
    self.destroy
  end

=begin  
  def self.admins_always_access
    User.where("type_of_user = ?","0").each do |user|
      user.update_attribute(:always_access, true)
    end  
  end  
=end  

end

class FailedDeactivationException < Exception
  def message
    "This user is already deactivated"
  end
end

class FailedActivationException < Exception
  def message
    "This user is already activated"
  end
end
