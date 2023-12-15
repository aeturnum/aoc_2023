enum HandOrder
  HighCard
  OnePair
  TwoPair
  ThreeOfAKind
  FullHouse
  FourOfAKind
  FiveOfAKind
end

class Hand
  include Comparable(self)

  @bid : Int32
  @hand : String
  @values : Array(Int32)
  @order : HandOrder

  getter bid : Int32
  getter order : HandOrder
  getter values : Array(Int32)
  # If there are problems check if these need adjusting
  VALUES = {
    '2' => 1,
    '3' => 2,
    '4' => 3,
    '5' => 4,
    '6' => 5,
    '7' => 6,
    '8' => 7,
    '9' => 8,
    'T' => 9,
    # part 1
    # 'J' => 10,
    # part 2
    'J' => 0,
    'Q' => 11,
    'K' => 12,
    'A' => 13,
  }

  def initialize(line : String)
    parts = line.split
    @bid = parts[1].strip.to_i
    @hand = parts[0].strip
    @values = @hand.chars.map do |c|
      VALUES[c]
    end
    @order = HandOrder::HighCard
    @order = self.make_order
  end

  private def make_order : HandOrder
    frequencies = Hash(Char, Int32).new
    @hand.delete('J').chars.each do |c|
      if frequencies[c]?
        frequencies[c] += 1
      else
        frequencies[c] = 1
      end
    end
    values = frequencies.values
    p! order = classify_freqs(values)
    p! upgrade(order, p! @hand.count('J'))
  end

  private def upgrade(order : HandOrder, joker_count : Int32)
    if joker_count == 0
      return order
    end

    case order.value
    when HandOrder::HighCard.value
      upgrade(HandOrder::OnePair, joker_count - 1)
    when HandOrder::OnePair.value
      upgrade(HandOrder::ThreeOfAKind, joker_count - 1)
    when HandOrder::TwoPair.value
      # If you have two pair and you're upgrading, you can only have 1 joker
      HandOrder::FullHouse
    when HandOrder::ThreeOfAKind.value
      upgrade(HandOrder::FourOfAKind, joker_count - 1)
    when HandOrder::FourOfAKind.value
      # no need to itterate
      HandOrder::FiveOfAKind
    else
      order
    end
  end

  private def classify_freqs(values) : HandOrder
    values.sort! # ascending
    # I did not handle the case where there are all jokers well but it's fine
    case values.pop?
    when 5 # 5 of a kind
      HandOrder::FiveOfAKind
    when 4 # 4 of a kind
      HandOrder::FourOfAKind
    when 3 # 3 of a kind / full house
      case values.pop?
      when 2
        HandOrder::FullHouse
      else
        HandOrder::ThreeOfAKind
      end
    when 2
      case values.pop?
      when 2
        HandOrder::TwoPair
      else
        HandOrder::OnePair
      end
    else
      HandOrder::HighCard
    end
  end

  def <=>(other : self) : Int32
    if @order == other.order
      @values.each_with_index do |v, i|
        if v != other.values[i]
          return v - other.values[i]
        end
      end
      # perfectly equal
      return 0
    else
      return @order.value - other.order.value
    end
  end

  def to_s(io : IO)
    io << "H[#{@order}]#{@hand}"
  end
end

class HandCollection
  def initialize
    @hands = Array(Hand).new
  end

  def add(hand : Hand)
    puts hand
    @hands << hand
  end

  def total_winnings
    sum = 0
    self.ranks.each do |r, h|
      sum += h.bid * r
    end
    return sum
  end

  private def ranks
    @hands.sort!
    r = Array(Tuple(Int32, Hand)).new
    @hands.each_with_index do |h, i|
      r << {i + 1, h}
    end
    return r
  end
end

# p! Hand.new("QKKKK 618")
# hands = Array(Hand).new
hands = HandCollection.new
File.read("./input").split("\n").each do |line|
  h = Hand.new(line)
  hands.add(h)
  #   puts "#{h} > #{hands[0]} = #{h > hands[0]}"
end
p! hands.total_winnings
# hands.sort!
# hands.each_with_index do |h, i|
#   puts "#{i} #{h}"
# end
