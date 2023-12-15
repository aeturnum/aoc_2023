require "big"

class Race
  @time : Int128
  @record : Int128

  def initialize(@time, @record)
    @possiblities = Hash(Int128, BigInt).new
    Range.new(0, @time).each do |hold_time|
      left = @time - hold_time
      @possiblities[hold_time.to_i128] = BigInt.new(hold_time) * left
    end
  end

  def beat_record : Array(BigInt)
    r = Array(BigInt).new
    @possiblities.each_value do |v|
      if v > @record
        r << v
      end
    end
    r
  end
end

# parts = File.read("./input").split("\n").map { |l| l.split(':')[1].strip.split }
# races = Array(Race).new
# parts[0].each_with_index do |time_str, i|
#   races << Race.new(time_str.to_i, parts[1][i].to_i)
# end
# sum_counts = 1
# races.each do |race|
#   sum_counts *= race.beat_record.size
# end
# p! sum_counts
# ah yes, using a compiled language lol
r1 = Race.new(46828479, 347152214061471)
p! r1.beat_record.size
