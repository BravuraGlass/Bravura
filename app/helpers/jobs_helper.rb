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
      prev_address << "<small>previous address : #{job.object.prev_address.try(:address)}<small> " 
      prev_address << link_to('[pick this]', 'javascript:void(0)', id: 'pick_address', data: {address: "#{job.object.prev_address.try(:address)}", latitude: "#{job.object.prev_address.try(:latitude)}", longitude: "#{job.object.prev_address.try(:longitude)}"})
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
end
