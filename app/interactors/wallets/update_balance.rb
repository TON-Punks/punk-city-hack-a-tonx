class Wallets::UpdateBalance
  include Interactor

  delegate :wallet, to: :context
  delegate :user, to: :wallet

  def call
    client = TonhubClient.new
    result = client.account(address: wallet.base64_address_bounce)
    return unless result

    new_balance = result["balance"]["coins"].to_i

    return if new_balance == wallet.balance

    sum = user.created_rock_paper_scissors_games.not_finished.with_ton_bet.pluck("bet").map(&:to_i).sum
    sum += user.participated_rock_paper_scissors_games.started.with_ton_bet.pluck("bet").map(&:to_i).sum

    wallet.update!(balance: new_balance, virtual_balance: new_balance - sum)

    Telegram::Notifications::NewBalance.call(user: wallet.user)
  end
end
