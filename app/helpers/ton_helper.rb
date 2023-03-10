module TonHelper
  def from_nano(nano_number, round = false)
    number = nano_number.to_i / 1_000_000_000.0
    number = number.round(2) if round
    Kernel.sprintf(number.to_s)
  end

  def to_nano(num)
    (num * 1_000_000_000).to_i
  end
end
