class Praxis::Withdraw
  include Interactor
  include TonHelper

  MIN = 500
  MAX = 5000

  PRAXIS_COMISSION_FEE = 0.1
  TON_FEE = 0.99

  delegate :user, :receiving_address, :praxis_amount, to: :context

  def call
    ApplicationRecord.transaction do
      validate_receiving_wallet_presence!
      validate_receiving_praxis_amount!

      create_sent_praxis_transaction!
      create_receive_praxis_transaction!

      validate_praxis_balance_valid!

      perform_ton_payment!
      log_user_ton_fee_transaction!
      send_receiver_notification
    end
  end

  private

  def validate_receiving_wallet_presence!
    context.fail!(error_message: I18n.t("bank.withdraw.errors.invalid_receiving_wallet")) if receiving_wallet.blank?
  end

  def validate_receiving_praxis_amount!
    if praxis_amount_to_receive < MIN || praxis_amount_to_receive > MAX
      context.fail!(error_message:
        I18n.t("bank.withdraw.errors.invalid_praxis_amount",
               praxis: praxis_amount_to_receive,
               praxis_min: MIN,
               praxis_max: MAX
             )
      )
    end
  end

  def create_sent_praxis_transaction!
    user.praxis_transactions.create!(
      operation_type: PraxisTransaction::P2P_SENT,
      quantity: praxis_amount_to_send
    )
  end

  def create_receive_praxis_transaction!
    receiving_wallet.user.praxis_transactions.create!(
      operation_type: PraxisTransaction::P2P_RECEIVED,
      quantity: praxis_amount_to_receive
    )
  end

  def validate_praxis_balance_valid!
    unless user.praxis_balance_valid?
      context.fail!(error_message: I18n.t("bank.withdraw.errors.insufficient_praxis_balance"))
    end
  end

  def perform_ton_payment!
    payment_result = BlackMarket::TonPaymentProcessor.call(ton_price: TON_FEE, user: user)
    context.fail!(error_message: payment_result.error_message) unless payment_result.success?
  end

  def praxis_amount_to_send
    @praxis_amount_to_send ||= (praxis_amount_to_receive * (1 + PRAXIS_COMISSION_FEE)).to_i
  end

  def praxis_amount_to_receive
    @praxis_amount_to_receive ||= praxis_amount.to_i
  end

  def receiving_wallet
    @receiving_wallet ||= Wallet.where(base64_address_bounce: receiving_address)
                                .or(Wallet.where(base64_address: receiving_address))
                                .first
  end

  def log_user_ton_fee_transaction!
    UserTransaction.create!(
      user_session: user.sessions.open.first,
      user: user,
      total: to_nano(TON_FEE),
      commission: to_nano(TON_FEE),
      transaction_type: 'praxis_withdraw'
    )
  end

  def send_receiver_notification
    Telegram::Notifications::NewPraxisTransaction.call(
      user: receiving_wallet.user,
      praxis_amount: praxis_amount_to_receive,
      praxis_sender: user.username
    )
  end
end
