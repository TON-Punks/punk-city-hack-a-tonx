class CreateRockPaperScissorsStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :rock_paper_scissors_statistics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.float :winrate
      t.bigint :ton_won
      t.bigint :ton_lost
      t.bigint :games_won
      t.bigint :games_lost

      t.timestamps
    end
  end
end
