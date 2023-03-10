class ChangeBalanceFromIntegerToBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :wallets, :balance, :bigint
  end
end
