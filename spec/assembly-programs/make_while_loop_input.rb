(10..110).each_with_index do |value, i|
  if i % 10 == 0
    puts ""
  end
  print value.to_s.rjust(4)
end
