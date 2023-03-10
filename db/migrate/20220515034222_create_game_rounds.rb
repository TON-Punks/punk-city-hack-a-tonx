class CreateGameRounds < ActiveRecord::Migration[6.1]
  def change
    create_table :game_rounds do |t|
      t.belongs_to :rock_paper_scissors_game, null: false, foreign_key: true, index: true
      t.string :winner
      t.integer :opponent
      t.integer :creator

      t.timestamps
    end
  end
end
