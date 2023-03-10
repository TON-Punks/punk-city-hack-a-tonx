class CreateWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :wallets do |t|
      t.string :address
      t.text :public_key
      t.text :secret_key
      t.text :mnemonic
      t.integer :balance

      t.timestamps
    end
  end
end
