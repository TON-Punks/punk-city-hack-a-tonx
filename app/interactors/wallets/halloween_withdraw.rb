class Wallets::HalloweenWithdraw
  include Interactor
  include RedisHelper

  delegate :withdraw_request, :dry_run, to: :context
  delegate :wallet, to: :withdraw_request

  WITHDRAW_WALLET_PATH = Rails.root.join("node_scripts/halloween_purchase.js")

  def call
    with_lock "withdraw-#{wallet.id}" do |locked|
      if locked
        return context.fail! if wallet.balance < withdraw_request.amount || wallet.virtual_balance < withdraw_request.amount
        everything = wallet.balance == withdraw_request.amount
        wallet_credential = wallet.credential

        user1, user2 = User.joins(:punk, :wallet).where(wallets: { state: :active }).order("RANDOM()").take(2)
        punk1_address = user1.wallet.base64_address_bounce
        punk2_address = user2.wallet.base64_address_bounce
        env = "PUBLIC_KEY=#{wallet_credential.public_key} SECRET_KEY=#{wallet_credential.secret_key} NANO_VALUE=#{withdraw_request.amount} ADDRESS=#{withdraw_request.address} EVERYTHING=#{everything} PUNK1_ADDRESS=#{punk1_address} PUNK2_ADDRESS=#{punk2_address}"
        node_output = dry_run ? '' : `#{env} node #{WITHDRAW_WALLET_PATH}`

        error = node_output.match(/error: (.*)/)
        raise RuntimeError, node_output if error

        wallet.decrement!(:balance, withdraw_request.amount)
        wallet.decrement!(:virtual_balance, withdraw_request.amount)

        Telegram::Notifications::HalloweenRaffleVictory.call(user: user1)
        Telegram::Notifications::HalloweenRaffleVictory.call(user: user2)
        Telegram::Notifications::HalloweenRaffleVictories.call(user1: user1, user2: user2)
      end
    end
  end
end
