class RepExperience::BaseChangesCalculator
  include Interactor

  delegate :data, to: :context

  MIN_EXP = 2
  MAX_EXP = 5

  REP_THRESHOLD = 10

  def call
    context.data = data.map do |user_data|
      user = User.find_by(chat_id: user_data[:chat_id])

      next if user.blank?
      rep_change = user_data[:rep] - user.chat_rep

      next if rep_change.zero?

      {
        user: user,
        rep_change: rep_change.to_i,
        exp_to_add: calculated_exp(rep_change.abs).to_i
      }
    end.compact
  end

  private

  def calculated_exp(rep_change)
    if rep_change > REP_THRESHOLD
      MAX_EXP * REP_THRESHOLD + (rep_change - REP_THRESHOLD) * MIN_EXP
    else
      rep_change * MAX_EXP
    end
  end
end
