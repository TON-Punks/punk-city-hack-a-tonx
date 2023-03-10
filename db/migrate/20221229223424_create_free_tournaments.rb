class CreateFreeTournaments < ActiveRecord::Migration[6.1]
  def change
    create_table :free_tournaments do |t|
      t.integer :state, null: false
      t.datetime :start_at, null: false
      t.datetime :finish_at, null: false
      t.bigint :prize_amount, null: false
      t.integer :prize_currency, null: false

      t.timestamps
    end
  end
end
