class AddStateToWallets < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :state, :integer, null: false, default: 0
  end
end
