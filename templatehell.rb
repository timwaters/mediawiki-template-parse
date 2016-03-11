string = "
div class='asccas'>
            <span class='ascascasc'>collect!                   &rarr; Enumerator</span>
            
          </div>
{Other
|param1 = value1
|param2=value2
|param3
|param4=
|nested1 = {{ru|Тарту}}
|nested2 = {{ru|1=СССР}}
}} 

{{Map
|param1 = value1
|latitude=345
|param3
|param4=
|nested1 = {{ru|Тарту}}
|nested2 = {{ru|1=СССР}}
}}


{{Another
|param1 = value1
|param2=value2
|param3
|param4=345.0/789.0
|nested1 = {{ru|Тарту}}
|nested2 = {{ru|1=СССР}}
}}"


def change_template(str, bbox)
  map_attrs = str.split("|")

  new_attrs = []
  map_template_attrs = []
  
  bbox_array  = bbox.split(",").map{|s| s.to_f.round(7)}
  longitude = "#{bbox_array[0]}/#{bbox_array[2]}"
  latitude = "#{bbox_array[1]}/#{bbox_array[3]}"

  something_changed  = false
          
  map_attrs.each do | map_attr |

    if map_attr.split("=").size == 2 && !map_attr.include?("<!--")
      key, value = map_attr.split("=")
      
      if key.include? "warped"
        unless value.include?("yes")  # don't edit if it's already there
          something_changed = true
          map_attr = "warped=yes\n"
        end    
      end

      if key.include? "latitude"
        if value.strip != latitude
          something_changed = true
          map_attr = "latitude=#{latitude}\n"  
        end
      end
      
      if key.include? "longitude"
        if value.strip != longitude
          something_changed = true
          map_attr = "longitude=#{longitude}\n"  
        end
      end
      
      map_template_attrs << map_attr
      
    end ## size > 2
    
    new_attrs << map_attr
    
  end
  
  #if it has help warp but no warped, we have to add in warped
  if map_template_attrs.any? { | s| (s.include?("help warp") or s.include?("help_warp"))} && map_template_attrs.none? {|s| s.include? "warped"}
    something_changed = true
    new_attrs.insert(2, "warped=yes\n")
  end
  
  map_template = new_attrs.join("|")

  if something_changed
    return map_template
  else
    return nil
  end

end

#
# returns the index of the end of the first template in the passed in string 
# will return false if no ending characters can be determined
#
def find_end_index(str)
  
  open_bracket = ["{", "{"]
  close_bracket = ["}", "}"]
  stack = []
  end_index = nil
  
  str.each_char.each_cons(2).with_index.each do | pair, index |
    if pair == open_bracket
      stack.push pair
    elsif pair == close_bracket
      x = stack.pop
      if stack.empty?
        puts "end of template"
        puts "index " + index.to_s
        end_index = index + 1
        return end_index
      end
    end
  #puts "stack" + stack.to_s
  end
  
  return stack.empty?
end

map_match = /\{{2}\s*(Map|Template:map)(.*)}}/mi.match(string)
string_start_index = string.index(/\{{2}\s*(Map|Template:map)(.*)}}/mi)
template_end_index  = nil
puts "start in string = " + string_start_index.to_s
if map_match
  map_template = map_match[0]
  template_end_index = find_end_index(map_template)
end
string_stop_index = string_start_index+template_end_index

if map_template && template_end_index

  map_template_string =  string[string_start_index..(string_stop_index)]

  bbox = "123,345,567,789"
  new_template = change_template(map_template_string, bbox)
  puts new_template.inspect
  if new_template 
    string[string_start_index..(string_stop_index+1)] = new_template
    puts "changing"
  else
    puts "nothing changed"
  end
  
  puts "full string"
  puts string
end
