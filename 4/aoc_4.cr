class Card
  @id : Int32

  getter id : Int32

  def initialize(info : String)
    # Card   1: 42 68 56  3 28 97  1 78 55 48 | 78 54  3 38 94 73 72 57 51 31 86 43  7 81  4 27 26 58 75 69 74 55  5 28 40
    info = info.split(':')
    @id = parse_id(info[0])
    @winners = Set(Int32).new
    @numbers = Set(Int32).new
    numbers = info[1].split('|')
    fill_set(@winners, numbers[0])
    fill_set(@numbers, numbers[1])
  end

  def winners
    @winners & @numbers
  end

  def score
    if self.winners.size == 0
      0.0
    else
      Math.exp2(self.winners.size - 1)
    end
  end

  def successors
    count = self.winners.size
    next_id = @id + 1
    result = Array(Int32).new
    while next_id <= @id + count
      result << next_id
      next_id += 1
    end
    result
  end

  private def fill_set(set : Set(Int32), num_list : String)
    num_list.split.each do |n|
      set << n.to_i
    end
  end

  private def parse_id(card_string : String)
    parts = card_string.split
    parts[1].to_i
  end

  def to_s(io : IO)
    io << "C#{@id}{#{self.winners}}[#{self.score}]"
  end
end

class CardIndex
  @card_idx : Hash(Int32, Card)
  @cache : Hash(Int32, Int32)

  def initialize
    @card_idx = Hash(Int32, Card).new
    @cache = Hash(Int32, Int32).new
  end

  def total_count
    count = 0
    @card_idx.keys.each do |k|
      count += self.card_count(k)
    end
    count
  end

  def warm_cache
    keys = @card_idx.keys.sort
    next_key = keys.pop?
    while next_key
      card_count(next_key)
      next_key = keys.pop?
    end
  end

  def add(card : Card)
    @card_idx[card.id] = card
  end

  def card_count(index : Int32)
    if @cache.has_key?(index)
      puts "card_count(#{index}) -> #{@cache[index]}"
      @cache[index]
    else
      val = self.calc_card_count(index)
      @cache[index] = val
      puts "card_count(#{index}) -[calc]> #{val}"
      val
    end
  end

  private def calc_card_count(index : Int32)
    card_stack = @card_idx[index].successors
    # puts "calc_card_count(#{index}) : #{card_stack}"
    card_count = 1
    next_card = card_stack.pop?
    while next_card
      card_count += self.card_count(next_card)
      next_card = card_stack.pop?
    end
    card_count
  end
end

data = File.read("./input")
score_sum = 0
card_index = CardIndex.new
data.each_line do |l|
  c = Card.new l
  puts c
  p! c.successors
  card_index.add(c)
  score_sum += c.score
end
p! score_sum

card_index.warm_cache

p! card_index.total_count
