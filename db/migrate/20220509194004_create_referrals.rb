class CreateReferrals < ActiveRecord::Migration[6.1]
  def change
    create_table :referrals do |t|
      t.belongs_to :user, null: false, foreign_key: { to_table: :users }, index: true
      t.belongs_to :referred, null: true, foreign_key: { to_table: :users }, index: { unique: true }

      t.timestamps
    end
  end
end
