class AddUserReferenceToWallet < ActiveRecord::Migration[6.1]
  def change
    add_reference(:wallets, :user, foreign_key: true, index: true)
  end
end
