class CreateUserHalloweenStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :user_halloween_statistics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.bigint :total_damage

      t.timestamps
    end
  end
end
