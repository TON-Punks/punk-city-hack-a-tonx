class CreatePlatformerStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :platformer_statistics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :top_score, null: false, default: 0

      t.timestamps
    end
  end
end
