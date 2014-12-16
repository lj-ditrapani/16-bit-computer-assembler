(10..110).each_with_index do |value, i|
  puts '' if i % 10 == 0
  print value.to_s.rjust(4)
end
