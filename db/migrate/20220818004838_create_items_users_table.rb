class CreateItemsUsersTable < ActiveRecord::Migration[6.1]
  def change
    create_table :items_users do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.json :data, null: false, default: {}

      t.timestamps
    end
  end
end
