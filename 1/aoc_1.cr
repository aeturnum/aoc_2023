DIGITS = {
  "one"   => 1,
  "two"   => 2,
  "three" => 3,
  "four"  => 4,
  "five"  => 5,
  "six"   => 6,
  "seven" => 7,
  "eight" => 8,
  "nine"  => 9,
  "zero"  => 0,
}

def parse_line(line)
  digits = Array(Int32).new
  line = line.downcase
  line.each_char_with_index do |c, i|
    three_ahead = DIGITS[line[i..i + 2]]?
    four_ahead = DIGITS[line[i..i + 3]]?
    five_ahead = DIGITS[line[i..i + 4]]?
    digit = c.to_i?
    digits << digit unless digit.nil?
    if three_ahead.nil?
      if four_ahead.nil?
        digits << five_ahead unless five_ahead.nil?
      else
        digits << four_ahead
      end
    else
      digits << three_ahead
    end
  end
  val = "#{digits[0]}#{digits[-1]}".to_i
  puts "#{line} -> #{digits} -> #{val}"
  return val
end

content = File.read("input")

sum = 0
content.each_line do |l|
  sum += parse_line(l)
end
p! sum
