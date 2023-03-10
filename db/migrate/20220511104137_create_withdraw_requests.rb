class CreateWithdrawRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :withdraw_requests do |t|
      t.string :address
      t.bigint :amount
      t.belongs_to :wallet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
