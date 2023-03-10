class CreateUserTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :user_transactions do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :user_session, null: true, foreign_key: true
      t.bigint :total, null: false
      t.bigint :commission, null: false
      t.string :transaction_type, null: false

      t.timestamps
    end
  end
end
