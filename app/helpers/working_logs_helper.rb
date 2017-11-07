module WorkingLogsHelper
  def time_diff(total_seconds)

    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)

    format("%02d:%02d:%02d", hours, minutes, seconds) #=> "01:00:00

  end
  
  def hours_opts(therange)
    rs = []
    therange.to_a.each do |num|
      if num.to_s.size == 1
        rs << ["0#{num}",num]
      else
        rs << [num,num]
      end    
    end  
    return rs
  end  
  
  def bhours
    hours_opts(0..23)
  end
  
  def bminutes  
    hours_opts(0..59)  
  end
  
  def bseconds
    bminutes
  end       
end
