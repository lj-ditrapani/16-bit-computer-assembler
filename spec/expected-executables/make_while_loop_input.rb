(10..110).each do |value|
  puts value.to_s(16).upcase.rjust(4, '0')
end
