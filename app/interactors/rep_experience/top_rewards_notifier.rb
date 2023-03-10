class RepExperience::TopRewardsNotifier
  include Interactor

  delegate :data, to: :context

  def call
    Telegram::Notifications::NewTopRepRewards.call(score: top_exp_gainers) if top_exp_gainers.present?
  end

  private

  def top_exp_gainers
    @top_exp_gainers ||= data.sort_by { |user_data| user_data[:exp_to_add] }.last(5).reverse
  end
end
