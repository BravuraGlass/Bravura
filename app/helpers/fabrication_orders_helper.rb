module FabricationOrdersHelper
  def options_for_master(forder)
    options_for_select(forder.rooms.where("master is NOT NULL AND master!=''").order("rooms.master").collect {|room| [room.master, room.id]})
  end 
  
  def master_formatting(room)
    if room.master.blank? == false and room.room_id.nil?
      raw "<b>#{room.master}</b>"
    elsif room.room
      room.room.master 
    else
      ""
    end      
  end   
  
  def next_room
    if @fabrication_order.rooms.size > 0
      "Next Room : " + content_tag(:span, @fabrication_order.rooms.last.nextname, id: "next_room_span")
    end  
  end  
end
