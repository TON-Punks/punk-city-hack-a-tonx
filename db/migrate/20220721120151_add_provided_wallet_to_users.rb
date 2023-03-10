class AddProvidedWalletToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :provided_wallet, :string
  end
end
