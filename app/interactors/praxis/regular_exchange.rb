class Praxis::RegularExchange < Praxis::BaseExchange
  def perform
    if user.effective_experience < Praxis::RegularExchangeWorker::EXPERIENCE_AMOUNT
      context.fail!(error_message: I18n.t("bank.fast_exchange.errors.insufficient_experience"))
    end

    context.fail!(error_message: I18n.t("bank.regular_exchange.errors.already_queued")) if ongoing_exchange_manager.time_left.present?

    Praxis::RegularExchangeWorker.perform_in(regular_time_calculator.interval, user.id)
    block_exchange_creation
  end

  private

  def regular_time_calculator
    @regular_time_calculator ||= Praxis::RegularExchange::TimeCalculator.call(user)
  end

  def block_exchange_creation
    ongoing_exchange_manager.set_time_left(regular_time_calculator.interval)
  end

  def ongoing_exchange_manager
    @ongoing_exchange_manager ||= Praxis::RegularExchange::OngoingExchangeManager.new(user.id)
  end
end
