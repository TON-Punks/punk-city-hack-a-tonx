class CreateBattlePasses < ActiveRecord::Migration[6.1]
  def change
    create_table :battle_passes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :kind

      t.timestamps
    end
  end
end
