class Num
  @x : Int32
  @y : Int32
  @length : Int32
  @valid : Bool
  @val : String

  getter length : Int32
  getter valid : Bool

  def initialize(@x, @y, parent : Schematic)
    # puts "{#{@y}, #{@x}}"
    @length = 0
    members = Array(Char).new
    v = parent.val(@x, @y).to_i?
    while !v.nil?
      # make sure we enque before check
      members << parent.val(@x + @length, @y)
      @length += 1
      v = parent.val(@x + @length, @y).to_i?
    end
    @val = members.join

    y = @y - 1
    x = @x - 1
    @valid = false
    while y < @y + 2
      if y != @y || (x < @x || x >= @x + @length)
        neighbor = parent.val(x, y)
        # puts "{#{y},#{x}} => #{neighbor}"
        if neighbor != '.'
          @valid = true
        end
      else
        # puts "{#{y},#{x}} => skip"
      end
      # 01234
      # .....0
      # .333.1
      # .....2
      # {x:1, y:1, len: 3}
      # -> {0,0}{0,4}
      # -> {2,0}{2,4}
      x += 1
      if x > @x + @length
        # next row
        y = y + 1
        x = @x - 1
      end
    end
  end

  def in?(x, y)
    y == @y && (x >= @x && x <= @x + @length - 1)
  end

  def value
    v = @val.to_i?
    if v.nil?
      0
    else
      v
    end
  end

  def to_s(io : IO)
    v = @valid ? 'V' : '_'
    io << "#{@val}[#{v}]"
  end
end

class Schematic
  @s : Array(String)
  @nums : Array(Num)

  def initialize(path : String)
    data = File.read(path)
    part_sum = 0
    @nums = Array(Num).new
    @s = data.split
    @s.each_with_index do |line, y|
      skip = 0
      line.each_char_with_index do |c, x|
        val = c.to_i?
        if skip > 0
          skip -= 1
        else
          if !val.nil?
            n = Num.new x, y, self
            @nums << n
            # puts n
            if n.valid
              part_sum += n.value
            end
            skip = n.length - 1
          end
        end
      end
    end

    p! part_sum
  end

  def find_stars
    # This is a bad solution but it will suffice for this task
    gear_ratios = 0
    @s.each_with_index do |line, y|
      line.each_char_with_index do |c, x|
        if c == '*'
          puts "#{y}, #{x}"
          vals = Set(Num).new
          y_aura = y - 1
          x_aura = x - 1
          while y_aura < y + 2
            @nums.each do |n|
              if n.in?(x_aura, y_aura)
                vals << n
              end
            end
            x_aura += 1
            if x_aura > x + 1
              # next row
              y_aura = y_aura + 1
              x_aura = x - 1
            end
          end
          if vals.size == 2
            a = vals.to_a
            ratio = a[0].value * a[1].value
            p! ratio
            gear_ratios += ratio
          end
        end
      end
    end
    p! gear_ratios
  end

  def val(x : Int32, y : Int32) : Char
    if y < 0 || y >= @s.size
      '.'
    else
      line = @s[y]
      if x < 0 || x >= line.size
        '.'
      else
        line[x]
      end
    end
  end
end

s = Schematic.new "./input"
s.find_stars
