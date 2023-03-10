class CreateReferralRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :referral_rewards do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :referral, null: false, foreign_key: { to_table: :users }
      t.belongs_to :rock_paper_scissors_game, null: false, foreign_key: true
      t.integer :experience, null: false, default: 0
      t.integer :praxis, null: false, default: 0
      t.decimal :ton, precision: 16, scale: 10, null: false, default: 0

      t.timestamps
    end

    add_index :referral_rewards, %i[user_id rock_paper_scissors_game_id], unique: true,
      name: "index_referral_rewards_on_users_and_game"
  end
end
