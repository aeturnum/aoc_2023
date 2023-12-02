content = File.read("input")

class Reveal
  getter r : Int32
  getter b : Int32
  getter g : Int32

  def initialize(cubes : String)
    @r = 0
    @b = 0
    @g = 0
    cubes.split(',') { |s|
      vals = s.split
      val = vals[0].to_i
      case vals[1]
      when "red"
        @r = val
      when "green"
        @g = val
      when "blue"
        @b = val
      end
    }
  end

  def possible(r : Int32, g : Int32, b : Int32)
    r >= @r && g >= @g && b >= @b
  end

  def to_s(io : IO)
    io << "{R:#{@r},G:#{@g},B:#{@b}}"
  end
end

class Game
  @id : Int32
  @reveals : Array(Reveal)

  getter id : Int32

  def initialize(line : String)
    @reveals = Array(Reveal).new
    @reqs = {0, 0, 0}
    info = line.split(':')
    id = info[0].split.[-1].to_i?
    if id.nil?
      @id = 0
    else
      @id = id
    end
    info[1].split(';') { |rev_str|
      rev = Reveal.new rev_str
      @reveals << rev
      @reqs = {
        Math.max(@reqs[0], rev.r),
        Math.max(@reqs[1], rev.g),
        Math.max(@reqs[2], rev.b),
      }
    }
  end

  def power
    @reqs[0] * @reqs[1] * @reqs[2]
  end

  def possible(r, g, b)
    @reveals.all? { |rev| rev.possible(r, g, b) }
  end

  def to_s(io : IO)
    io << "#{@id}[#{@reqs}]:[#{@reveals.join(", ")}]"
  end
end

id_sum = 0
power_sum = 0
content.each_line do |l|
  game = Game.new l
  puts game
  if game.possible(12, 13, 14)
    id_sum += game.id
  end
  power_sum += game.power
end
p! id_sum
p! power_sum
