class AddBase64AddressToWallets < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :base64_address_bounce, :string
    add_column :wallets, :base64_address, :string
  end
end
