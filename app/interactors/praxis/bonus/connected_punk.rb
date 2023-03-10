class Praxis::Bonus::ConnectedPunk
  include Interactor

  ADDITIONAL_PUNK_REWARD = 5
  DAY_REWARDS_MAPPING = {
    (1..2) => 5,
    (3..4) => 6,
    (5..6) => 7,
    (7..8) => 8,
    (8..9) => 9,
    (10..11) => 10,
    (12..13) => 11,
    (14..15) => 12,
    (16..17) => 12,
    (18..19) => 13,
    (20..21) => 14,
    (22..23) => 15,
    (24..25) => 16,
    (26..27) => 17,
    (28..29) => 18,
    (30..31) => 19,
    (32..33) => 20,
    (34..35) => 21,
    (36..37) => 22,
    (38..39) => 23,
    (40..41) => 24,
    (42..43) => 25,
    (44..45) => 26,
    (46..47) => 27,
    (48..49) => 28,
    (50..51) => 29,
    (52..) => 30
  }

  BASE_EXP_REWARD = 300
  ADDITIONAL_EXP_REWARD = 30

  delegate :user, :rewarded_punks_ids, to: :context

  def call
    return if rewarded_punks_ids.include?(user.punk.id)
    return if days_since_connected.zero?
    return unless current_day_reward.positive?

    add_rewards_and_notify unless already_rewarded?
    context.new_rewarded_punks_ids = new_rewarded_punks_ids
  end

  private

  def add_rewards_and_notify
    ApplicationRecord.transaction do
      add_praxis!
      add_experience!
    end

    send_notification
  end

  def already_rewarded?
    user.praxis_transactions.connected_punk_bonus.where(created_at: 12.hours.ago..).any?
  end

  def new_rewarded_punks_ids
    [user.punk.id] + additional_punks_ids
  end

  def add_praxis!
    user.praxis_transactions.connected_punk_bonus.create!(quantity: current_day_reward + additional_punks_praxis_reward)
  end

  def add_experience!
    user.add_experience!(BASE_EXP_REWARD + additional_exp_reward)
  end

  def additional_exp_reward
    @additional_exp_reward ||= additional_punks_ids.count * ADDITIONAL_EXP_REWARD
  end

  def send_notification
    user.with_locale do
      Telegram::Notifications::ConnectedPunkBonus.call(
        user: user,
        connected_days: days_since_connected,
        praxis_reward: current_day_reward,
        exp_reward: BASE_EXP_REWARD,
        additional_punks_count: additional_punks_ids.count,
        additional_praxis_reward: additional_punks_praxis_reward,
        additional_exp_reward: additional_exp_reward
      )
    end
  end

  def current_day_reward
    @current_day_reward ||= DAY_REWARDS_MAPPING.detect do |day_range, reward|
      day_range.include?(days_since_connected)
    end.last
  end

  def additional_punks_praxis_reward
    @additional_punks_praxis_reward ||= additional_punks_ids.count * ADDITIONAL_PUNK_REWARD
  end

  def days_since_connected
    @days_since_connected ||= (current_time.to_date - connected_at).to_i
  end

  def additional_punks_ids
    @additional_punks_ids ||= Punk.where(owner: punk.owner).where.not(id: [user.punk.id] + rewarded_punks_ids).pluck(:id)
  end

  def punk
    @punk ||= user.punk
  end

  def connected_at
    @connected_at ||= user.connected_punk_connection.connected_at.to_date
  end

  def current_time
    @current_time ||= Time.zone.now
  end
end
