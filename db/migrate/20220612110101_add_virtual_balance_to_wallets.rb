class AddVirtualBalanceToWallets < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :virtual_balance, :bigint, default: 0, null: false

    Wallet.update_all('virtual_balance = balance')
  end
end
