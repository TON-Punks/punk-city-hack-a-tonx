class BlackMarket::ProductPriceIncreaser
  DEFAULT_INCREASE_MULTIPLIER = 0.03

  MIN_INCREASE = 10
  MAX_INCREASE = 50

  class << self
    def call(product)
      new(product).call
    end
  end

  def initialize(product)
    @product = product
  end

  def call
    product.update!(current_price: (product.current_price + calculated_increase_amount).to_i)
  end

  private

  attr_reader :product

  def calculated_increase_amount
    return MIN_INCREASE if default_increase_amount < MIN_INCREASE
    return MAX_INCREASE if default_increase_amount > MAX_INCREASE

    default_increase_amount
  end

  def default_increase_amount
    @default_increase_amount ||= (product.current_price * DEFAULT_INCREASE_MULTIPLIER).to_i
  end
end
