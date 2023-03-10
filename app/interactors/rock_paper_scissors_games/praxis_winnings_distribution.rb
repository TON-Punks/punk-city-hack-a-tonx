class RockPaperScissorsGames::PraxisWinningsDistribution
  include Interactor

  WINNING_PAYOUT_RATIO = 0.8
  REFERAL_FEE_REWARD = 0.1

  delegate :game, to: :context
  delegate :creator, :opponent, to: :game

  def call
    ApplicationRecord.transaction do
      unreserve_balances
      distribute_winnings
      distribute_referral_reward
      raise ActiveRecord::Rollback unless creator.praxis_wallet.balance_valid? && opponent.praxis_wallet.balance_valid?
    end
  end

  private

  def unreserve_balances
    creator.praxis_wallet.unreserve(bet)
    opponent.praxis_wallet.unreserve(bet)
  end

  def distribute_winnings
    winner_user.praxis_transactions.game_won.create!(quantity: win_amount)
    losing_user.praxis_transactions.game_lost.create!(quantity: loss_amount)
  end

  def distribute_referral_reward
    return if referral_reward.zero?

    distribute_winner_referral_reward
    distribute_loser_referral_reward
  end

  def distribute_winner_referral_reward
    return if winner_user.referred_by.blank?

    winner_user.referred_by.praxis_transactions.referral_bonus.create!(quantity: referral_reward)
    ReferralReward.for(winner_user, game).update!(praxis: referral_reward)
  end

  def distribute_loser_referral_reward
    return if losing_user.referred_by.blank?

    losing_user.referred_by.praxis_transactions.referral_bonus.create!(quantity: referral_reward)
    ReferralReward.for(losing_user, game).update!(praxis: referral_reward)
  end

  def winner_user
    @winner_user ||= game.creator_won? ? creator : opponent
  end

  def losing_user
    @losing_user ||= game.creator_won? ? opponent : creator
  end

  def referral_reward
    @referral_reward ||= (bet * 0.1 * REFERAL_FEE_REWARD).floor
  end

  def win_amount
    @win_amount ||= (bet * WINNING_PAYOUT_RATIO).to_i
  end

  def loss_amount
    bet
  end

  def bet
    @bet ||= game.bet
  end
end
