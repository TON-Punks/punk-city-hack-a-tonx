class CreatePlatformerGames < ActiveRecord::Migration[6.1]
  def change
    create_table :platformer_games do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :score
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
