module UsersHelper
  def user_type_name(user_type)
    case user_type
    when "0"
      "System Admin"
    when "1"
      "Sales Representative"
    else
      "Field Worker"
    end
  end
  def is_admin(user)
     if user.type_of_user.eql?("0")
       true
     else
       false
     end
  end
  def is_salerep(user)
     if user.type_of_user.eql?("1")
       true
     else
       false
     end
  end
  def is_fieldwork(user)
     if user.type_of_user.eql?("2")
       true
     else
       false
     end
  end
end
