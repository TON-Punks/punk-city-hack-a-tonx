class UpgdateItemsType < ActiveRecord::Migration[6.1]
  def up
    add_column :items, :data_jsonb, :jsonb, default: {}
    add_column :items_users, :data_jsonb, :jsonb, default: {}

    # Copy data from old column to the new one
    Item.update_all('data_jsonb = data::jsonb')
    ItemsUser.update_all('data_jsonb = data::jsonb')

    # Rename columns instead of modify their type, it's way faster
    rename_column :items, :data, :data_json
    rename_column :items, :data_jsonb, :data
    rename_column :items_users, :data, :data_json
    rename_column :items_users, :data_jsonb, :data

    remove_column :items, :data_json
    remove_column :items_users, :data_json

    Item.where(data: nil).update_all(data: {})
    ItemsUser.where(data: nil).update_all(data: {})
    change_column_null :items, :data, false
    change_column_null :items_users, :data, false
  end

  def down
    remove_column :items, :data, default: '{}', null: false
    remove_column :items_users, :data, default: '{}', null: false

    add_column :items, :data, :json
    add_column :items_users, :data, :json
  end
end
