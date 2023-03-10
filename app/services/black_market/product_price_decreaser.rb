class BlackMarket::ProductPriceDecreaser
  DEFAULT_DECREASE_MULTIPLIER = 0.06

  class << self
    def call(product)
      new(product).call
    end
  end

  def initialize(product)
    @product = product
  end

  def call
    new_price = if calculated_new_price < product.min_price
                  product.min_price
                else
                  calculated_new_price
                end

    product.update!(current_price: new_price)
  end

  private

  attr_reader :product

  def calculated_new_price
    @calculated_new_price ||= (product.current_price - calculated_decrease_amount).to_i
  end

  def calculated_decrease_amount
    @calculated_decrease_amount ||= (product.current_price * DEFAULT_DECREASE_MULTIPLIER).to_i
  end
end
