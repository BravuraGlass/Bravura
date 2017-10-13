module ApplicationHelper
  def bts_datepicker(name, id = 'datepicker', input_options = {})
    datepicker_html =
      "<div id=\"#{id}\" class=\"input-group date\">
        <input type=\"text\" class=\"#{input_options[:class]}\">
        <span class=\"input-group-addon\">
          <span class=\"fa fa-calendar\"></span>
        </span>
      </div>"
    datepicker_html.html_safe


    # <div id="datetimepicker1" class="input-group date">
    #     <input type="text" class="form-control">
    #     <span class="input-group-addon">
    #       <span class="fa fa-calendar"></span>
    #     </span>
    # </div>
  end

end
