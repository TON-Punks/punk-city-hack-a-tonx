class AddIndexToWallets < ActiveRecord::Migration[6.1]
  def change
    add_index(:wallets, :base64_address_bounce)
  end
end
