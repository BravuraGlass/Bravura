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

  def prev_address(job)
    prev_address = ""
    if job.object.prev_address
      prev_address << "<small>Previous address : #{job.object.prev_address.try(:address)}</small> " 
      prev_address << link_to("Pick This", 'javascript:void(0)', id: 'pick_address', class: 'btn btn-default btn-xs', data: {address: "#{job.object.prev_address.try(:address)}", latitude: "#{job.object.prev_address.try(:latitude)}", longitude: "#{job.object.prev_address.try(:longitude)}"})
    end
    prev_address.html_safe
  end

  def prev_customer_address(job)
    prev_address = ""
    if job.customer.try(:address)
      prev_address << "<small>Previous address : #{job.customer.try(:address)}" 
      prev_address << ", Apt# #{job.customer.try(:address2)}" if job.customer.try(:address2)
      prev_address << "</small> "
      prev_address << link_to("Pick This", 'javascript:void(0)', id: 'pick_customer_address', class: 'btn btn-default btn-xs', data: {address: "#{job.customer.try(:address)}", address2: "#{job.customer.try(:address2)}", latitude: "#{job.try(:latitude)}", longitude: "#{job.try(:longitude)}"})
    end
    prev_address.html_safe
  end

  def prev_next_button(prev, next_obj)
    buttons = ""
    if prev && next_obj
      buttons << "<div class='dataTables_paginate '>"
      buttons << "<ul class='pagination small'>"
      if prev
        buttons << "<li class='previous'>"
        buttons << "<a href='#{job_path(prev)}'>Prev</a>"
        buttons << "</li>"
      end
      if next_obj
      buttons << "<li class='next'>"
      buttons << "<a href='#{job_path(next_obj)}'>Next</a>"
      buttons << "</li>"
      end
      buttons << "</ul>"
      buttons << "</div>"
    end
    buttons.html_safe
  end
  
  def d_appointment(dtime)
    unless dtime.nil? 
      return l(dtime, format: '%Y-%m-%d')
    else
      return nil
    end    
  end  
  
  def t_appointment(dtime)
    unless dtime.nil? 
      return l(dtime, format: '%H:%M:%S.%L')
    else
      return nil
    end    
  end 
end
