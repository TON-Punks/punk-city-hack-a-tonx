class CreateWalletCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :wallet_credentials do |t|
      t.belongs_to :wallet, null: false, foreign_key: true
      t.text :public_key
      t.text :secret_key
      t.text :mnemonic

      t.timestamps
    end
  end
end
