class Filter
  def initialize(block : String)
    # 50 98 2
    # 52 50 48

    # p! str
    @sections = Array(Tuple(Int64, Int64, Int64)).new
    block.strip.each_line do |line|
      #   p! line
      parts = line.split
      start = parts[1].to_i64
      output = parts[0].to_i64
      length = parts[2].to_i
      @sections << {start, start + length, output - start}
    end
    # p! @sections
  end

  def filter_value(v)
    @sections.each do |sec|
      if v >= sec[0] && v <= sec[1]
        return v + sec[2]
      end
    end
    v
  end
end

class SeedSource
  include Enumerable(Int64)

  @start : Int64
  @size : Int64

  def initialize(@start, @size)
  end

  def each(&)
    seed = @start
    while seed < @start + @size
      yield seed
      seed += 1
    end
  end
end

class SeedMap
  #   @seeds : Array(Int64)
  @seeds : Array(SeedSource)

  def initialize(path)
    sections = File.read(path).split("\n\n")
    @seeds = parse_seeds(sections.shift)
    @sections = Hash(String, Hash(String, Filter)).new
    sections.each do |sec|
      info = section_info(sec)
      if !@sections[info[0]]?
        @sections[info[0]] = Hash(String, Filter).new
      end

      @sections[info[0]][info[1]] = Filter.new(info[2])
      #   puts "-------"
    end
  end

  def seeds
    @seeds
  end

  def seed_to_other(value)
    input = value
    done = false
    last_section = "seed"
    next_section = last_section
    while next_section != "location"
      #   p! next_section
      if !@sections[next_section]
        puts "Warning: can't find #{next_section}"
      else
        hash = @sections[last_section]
        next_section = hash.keys[0]
        old_val = value
        # No else here, value stays the same
        value = hash[next_section].filter_value(value)
        # puts "#{last_section}{#{old_val}} -> #{next_section}{#{value}}"
        last_section = next_section
      end
      #   done = true
    end
    # puts "#{input} -> #{value}"
    value
  end

  private def parse_seeds(string : String) : Array(SeedSource)
    # seeds: 79 14 55 13
    inputs = Array(Int64).new
    string.split(':')[1].split.each do |num|
      inputs << num.to_i64
    end
    result = Array(SeedSource).new
    inputs.each_slice(2) do |slice|
      result << SeedSource.new(slice[0], slice[1])
    end
    result
  end

  # part one
  #   private def parse_seeds(string : String) : Array(Int64)
  #     # seeds: 79 14 55 13
  #     result = Array(Int64).new
  #     string.split(':')[1].split.each do |num|
  #       result << num.to_i64
  #     end
  #     result
  #   end

  # seed-to-soil map:
  # 50 98 2
  # 52 50 48
  private def section_info(sec : String)
    header = sec.split(':')[0].split
    if header[1] != "map"
      puts "Warning: Header not in expected format #{header}"
    end
    parts = header[0].split('-')
    [parts[0], parts[2], sec.split(':')[1]]
  end
end

# ss = SeedSource.new(0, 5)
# ss.each do |s|
#   p! s
# end

sm = SeedMap.new "./test"
min = nil
sm.seeds.each do |seed_map|
  p! seed_map
  seed_map.each do |seed|
    loc = sm.seed_to_other(seed)
    if min.nil?
      min = loc
    end

    if min > loc
      min = loc
    end
  end
end
p! min
