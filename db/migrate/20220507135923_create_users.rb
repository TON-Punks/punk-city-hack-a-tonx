class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :chat_id, null: false, index: { unique: true }
      t.string :username
      t.string :locale
      t.integer :level, null: false, default: 0

      t.timestamps
    end
  end
end
