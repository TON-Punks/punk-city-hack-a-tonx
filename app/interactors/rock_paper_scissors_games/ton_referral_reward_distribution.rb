class RockPaperScissorsGames::TonReferralRewardDistribution
  include Interactor
  include TonHelper

  COMISSION_AMOUNT = 0.1
  REFERAL_FEE_REWARD = 0.1

  MINIMAL_REWARD = 0.01

  delegate :game, to: :context
  delegate :creator, :opponent, to: :game

  def call
    return if referral_reward < MINIMAL_REWARD

    distribute_winner_bonus
    distribute_looser_bonus
  end

  private

  def distribute_winner_bonus
    return if winner_user.referred_by.blank?

    BlackMarket::ComissionPayoutWorker.perform_in(1.minute, winner_user.referred_by.id, referral_reward)
    ReferralReward.for(winner_user, game).update!(ton: referral_reward)
  end

  def distribute_looser_bonus
    return if losing_user.referred_by.blank?

    BlackMarket::ComissionPayoutWorker.perform_in(3.minutes, losing_user.referred_by.id, referral_reward)
    ReferralReward.for(losing_user, game).update!(ton: referral_reward)
  end

  def winner_user
    @winner_user ||= game.creator_won? ? creator : opponent
  end

  def losing_user
    @losing_user ||= game.creator_won? ? opponent : creator
  end

  def referral_reward
    @referral_reward ||= from_nano((bet * COMISSION_AMOUNT * REFERAL_FEE_REWARD).to_i).to_f
  end

  def bet
    @bet ||= game.bet
  end
end
