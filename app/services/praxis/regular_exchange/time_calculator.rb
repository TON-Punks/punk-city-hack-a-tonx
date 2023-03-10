class Praxis::RegularExchange::TimeCalculator
  DEFAULT_TIME = 60.minutes

  class << self
    def call(user)
      new(user).call
    end
  end

  def initialize(user)
    @user = user
  end

  def call
    Praxis::RegularExchangeTime.new(
      interval: interval,
      until_reset: until_reset,
      humanized_interval: humanized_time(interval),
      humanized_until_reset: humanized_time(until_reset),
      humanized_ongoing_interval: humanized_ongoing_interval
    )
  end

  private

  attr_reader :user

  def until_reset
    @until_reset ||= current_time.end_of_day - current_time
  end

  def humanized_ongoing_interval
    time_left = Praxis::RegularExchange::OngoingExchangeManager.new(user.id).time_left

    time_left.present? ? humanized_time(time_left) : ""
  end

  def interval
    @interval ||= (DEFAULT_TIME * (user.praxis_transactions.regular_exchange.for_today.count + 1)).to_i
  end

  def humanized_time(seconds)
    [
      [60, I18n.t("bank.regular_exchange.time.seconds"), false],
      [60, I18n.t("bank.regular_exchange.time.minutes"), true],
      [24, I18n.t("bank.regular_exchange.time.hours"), true],
      [Float::INFINITY, I18n.t("bank.regular_exchange.time.days"), false]
    ].map do |count, name, include|
      if seconds > 0
        seconds, n = seconds.divmod(count)

        "#{n.to_i}#{name}" if n.to_i != 0 && include
      end
    end.compact.reverse.join(' ')
  end

  def current_time
    @current_time ||= Time.now.utc
  end
end
