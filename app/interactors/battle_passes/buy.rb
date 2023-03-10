class BattlePasses::Buy
  include Interactor

  TOURNAMENT_DISTRIBUTER_ADDRESS = 'EQCn5geplkfL7oewoU9TWnuA-R858mU7X-zM7XRbxjMAVpGy'

  delegate :user, :count, to: :context
  delegate :wallet, to: :user

  TON_FEE = 5
  TICKETS_COUNT = 5

  def call
    payment_result = BlackMarket::TonPaymentProcessor.call(
      ton_price: TON_FEE,
      user: user,
      ton_fee_address: TOURNAMENT_DISTRIBUTER_ADDRESS,
      withdraw_class: Wallets::HalloweenWithdraw
    )
    context.fail!(error_message: payment_result.error_message) unless payment_result.success?

    tournament = Tournament.halloween
    battle_pass = user.battle_passes.create!(kind: :halloween)
    TICKETS_COUNT.times { TournamentTicket.create(user: user, tournament: tournament) }
  end
end
