    class AddNextStepToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :next_step, :string
  end
end
