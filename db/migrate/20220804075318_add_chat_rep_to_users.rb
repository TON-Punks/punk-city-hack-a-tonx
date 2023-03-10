class AddChatRepToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :chat_rep, :bigint, null: false, default: 0
  end
end
