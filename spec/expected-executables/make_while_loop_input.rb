(10..110).each_with_index do |value, i|
  puts value.to_s(16).upcase.rjust(4, '0')
end
