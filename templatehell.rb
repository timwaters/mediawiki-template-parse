string  = "
=={{int:filedesc}}==

{{Map
|title=Map of England from new systeme of the mathematicks, Mass
|author=Flamsteed, John 
|date=1681
|source=[http://digitalcollections.nypl.org/items/510d47e1-ceb9-a3d9-e040-e00a18064a99 NYPL Repo]
|location=England, Europe
|scale=10632
|institution={{Institution:New York Public Library}}
|dimensions={{Size|cm|87|70}}
}}

"

string2  = "

{{Map
|title=Map of England from new systeme of the mathematicks, Mass
|author=Flamsteed, John 
|date=1681
|source=[http://digitalcollections.nypl.org/items/510d47e1-ceb9-a3d9-e040-e00a18064a99 NYPL Repo]
|location=England, Europe
|scale=10632
|institution=3
|dimensions=2
}}

"

string3 = "
=={{int:filedesc}}==

foo

{{
  
  Map|title=Map of England from new systeme of the mathematicks, Mass
}}


#equals
#inner template
"



def change_template(str, bbox)
  map_attrs = str.split("|")
  puts  "  map_attrs = str.split('|')"
puts map_attrs.inspect

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
  

  if map_template_attrs.none? {|s| (s.include? "warp status") || (s.include? "Warp status") || (s.include? "warp_status") || (s.include? "Warp_status")}
    something_changed = true
    insert_at = new_attrs.size# >= 1 ? new_attrs.size  : 0
    new_attrs.insert(insert_at, "warp_status=warped\n")
  end
  
  if map_template_attrs.none? {|s| (s.include? "latitude") || (s.include? "Latitude") }
    something_changed = true
    insert_at = new_attrs.size# >= 1 ? new_attrs.size  : 0
    new_attrs.insert(insert_at, "latitude=#{latitude}\n" )
  end
  
  if map_template_attrs.none? {|s| (s.include? "longitude") || (s.include? "Longitude") }
    something_changed = true
    insert_at = new_attrs.size #>= 1 ? new_attrs.size  : 0
    new_attrs.insert(insert_at, "longitude=#{longitude}\n")
  end
  
  map_template = new_attrs.join("|")

  if something_changed
    
    return "{{"+ map_template+ "}}"
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

if map_match
  map_template = map_match[0]
  template_end_index = find_end_index(map_template)
end
string_stop_index = string_start_index+template_end_index

if map_template && template_end_index

  map_template_string =  string[string_start_index..(string_stop_index)]
puts "mpa template string="
puts map_template_string
puts " - "
trimmed = map_template_string.chomp[2..-3].lstrip
puts "trimmed"
puts trimmed
puts " - "

  bbox = "123,345,567,789"
  new_template = change_template(trimmed, bbox)
  puts new_template
  puts "---"
  if new_template 
    string[string_start_index..(string_stop_index+1)] = new_template
    puts "changing"
  else
    puts "nothing changed"
  end
  
  puts "full string"
  puts string
end
