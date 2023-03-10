class UserPraxisWallet
  INVALID_AMOUNT_ERROR = Class.new(StandardError)

  def initialize(user)
    @user = user
  end

  def balance
    user.praxis_transactions.balance
  end

  def reserve(amount)
    raise INVALID_AMOUNT_ERROR if balance < amount

    user.praxis_transactions.create!(operation_type: PraxisTransaction::RESERVED, quantity: amount)
  end

  def unreserve(amount)
    raise INVALID_AMOUNT_ERROR if amount > user.praxis_transactions.reserved_balance

    user.praxis_transactions.create!(operation_type: PraxisTransaction::UNRESERVED, quantity: amount)
  end

  def balance_valid?
    balance.zero? || balance.positive?
  end

  private

  attr_reader :user
end
