class CreatePraxisTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :praxis_transactions do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :operation_type, null: false
      t.bigint :quantity, null: false

      t.timestamps
    end
  end
end
