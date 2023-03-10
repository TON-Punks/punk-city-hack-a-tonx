class CreateRockPaperScissorsGames < ActiveRecord::Migration[6.1]
  def change
    create_table :rock_paper_scissors_games do |t|
      t.jsonb :rounds, null: false, default: []
      t.belongs_to :creator, user: true, null: false, foreign_key: { to_table: :users }
      t.belongs_to :opponent, user: true, null: true, foreign_key: { to_table: :users }
      t.boolean :bot, null: false, default: false
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
