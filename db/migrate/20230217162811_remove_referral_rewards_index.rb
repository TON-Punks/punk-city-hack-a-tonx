class RemoveReferralRewardsIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :referral_rewards, name: "index_referral_rewards_on_users_and_game"

    add_index :referral_rewards, %i[referral_id rock_paper_scissors_game_id], unique: true,
      name: "index_referral_rewards_on_referrals_and_game"
  end
end
