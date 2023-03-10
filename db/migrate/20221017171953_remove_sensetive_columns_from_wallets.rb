class RemoveSensetiveColumnsFromWallets < ActiveRecord::Migration[6.1]
  def change
    remove_column(:wallets, :secret_key)
    remove_column(:wallets, :public_key)
    remove_column(:wallets, :mnemonic)
  end
end
