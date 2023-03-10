class CreateSegmentsUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :segments_users do |t|
      t.references :segment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :segments_users, %i[segment_id user_id], unique: true
  end
end
