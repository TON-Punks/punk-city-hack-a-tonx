class BlackMarket::PurchaseHalloweenTickets < BlackMarket::BasePurchase
  include RedisHelper

  PRAXIS_PAYMENT_METHOD = 'praxis'
  TON_PAYMENT_METHOD = 'ton'

  PAYMENT_METHODS_MAPPING = {
    PRAXIS_PAYMENT_METHOD => :praxis_payment,
    TON_PAYMENT_METHOD => :ton_payment
  }

  TON_FEE = 2.5
  TICKETS_COUNT = 5
  TOURNAMENT_DISTRIBUTER_ADDRESS = 'EQCn5geplkfL7oewoU9TWnuA-R858mU7X-zM7XRbxjMAVpGy'

  delegate :user, :pay_method, to: :context

  def perform
    return context.fail!(error_message: I18n.t('halloween_event.purchase_tickets.errors.already_bought')) if purchase_today?

    ApplicationRecord.transaction do
      payment_result = begin
        send(PAYMENT_METHODS_MAPPING.fetch(pay_method))
      rescue KeyError
        context.fail!(error_message: I18n.t("common.error"))
      end

      tournament = Tournament.halloween
      TICKETS_COUNT.times { TournamentTicket.create(user: user, tournament: tournament) }

      save_today_purchase
    end
  end

  private

  def praxis_payment
    praxis_transaction = user.praxis_transactions.create!(
      operation_type: PraxisTransaction::PRODUCT_PURCHASE,
      quantity: product.current_price
    )

    if user.praxis_balance_valid?
      create_black_market_purchase!(praxis_transaction)
    else
      context.fail!(error_message: I18n.t("black_market.errors.not_enough_praxis"))
    end

    BlackMarket::ProductPriceIncreaser.call(product)
  end

  def ton_payment
    result = BlackMarket::TonPaymentProcessor.call(
      ton_price: TON_FEE,
      user: user,
      ton_fee_address: TOURNAMENT_DISTRIBUTER_ADDRESS,
      withdraw_class: Wallets::HalloweenWithdraw
    )

    context.fail!(error_message: result.error_message) unless result.success?

    create_black_market_purchase!
  end

  def create_black_market_purchase!(praxis_transaction = nil)
    user.black_market_purchases.create!(
      praxis_transaction: praxis_transaction,
      black_market_product: product,
      payment_method: pay_method,
      payment_amount: payment_amount
    )
  end

  def purchase_today?
    redis.get(ticket_purchase_key).present?
  end

  def save_today_purchase
    ttl = (Date.current.end_of_day + 4.hours).to_i - Time.current.to_i
    redis.setex(ticket_purchase_key, ttl, true)
  end

  def ticket_purchase_key
    "halloween-tickets-#{user.id}"
  end

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::HALLOWEEN_TICKETS)
  end

  def payment_amount
    pay_method == TON_PAYMENT_METHOD ? TON_FEE : product.current_price
  end

  def wallet_config
    @wallet_config ||= Rails.application.config_for(:contract_manager)
  end
end
