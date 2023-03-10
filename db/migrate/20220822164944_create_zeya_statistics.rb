class CreateZeyaStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :zeya_statistics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :top_score

      t.timestamps
    end
  end
end
