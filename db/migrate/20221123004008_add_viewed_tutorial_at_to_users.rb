class AddViewedTutorialAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :viewed_tutorial_at, :datetime
  end
end
