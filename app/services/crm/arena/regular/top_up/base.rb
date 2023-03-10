class Crm::Arena::Regular::TopUp::Base < Crm::Base
  private

  def matches_conditions?
    user.wallet.virtual_balance.zero?
  end

  def photo
    File.open(TelegramImage.path("crm/wallet_#{rand(1..3)}.png"))
  end
end
