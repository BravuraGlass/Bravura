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
