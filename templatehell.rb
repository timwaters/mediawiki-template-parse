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
|param2=value2
|param3
|param4=
|nested1 = {{ru|Тарту}}
|nested2 = {{ru|1=СССР}}
}} 


{{Another
|param1 = value1
|param2=value2
|param3
|param4=
|nested1 = {{ru|Тарту}}
|nested2 = {{ru|1=СССР}}
}}"



def end_template(str)
  
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
        end_index = index
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
  template_end_index = end_template(map_template)
end

puts "end index in template = "+template_end_index.to_s

map_template_string =  string[string_start_index..(string_start_index+template_end_index)]

puts map_template_string

puts "replacing"

string[string_start_index..(string_start_index+template_end_index+1)] = "foo bar"

puts "new string"
puts string
