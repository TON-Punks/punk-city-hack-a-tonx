class AddUtmSourceToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :utm_source, :string, if_not_exists: true
  end
end
