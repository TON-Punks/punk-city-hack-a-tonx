class AddMissingAttributesToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :kind, :string
    add_column :tournaments, :balance, :bigint, null: false, default: 0
    add_column :tournaments, :address, :string
    add_column :tournaments, :expires_at, :datetime
  end
end
