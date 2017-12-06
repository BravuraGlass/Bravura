module JobsHelper
  def column_color(idx)
    if idx == 0
      nil
    elsif idx.odd?
      'odd-color'
    else
      'even-color'
    end      
  end  
end
