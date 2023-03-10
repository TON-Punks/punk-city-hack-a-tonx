class AddExperienceToUsersAndPunks < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :experience, :bigint, null: false, default: 0
    add_column :punks, :experience, :bigint, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute "UPDATE users SET experience = total_experience"
        execute "UPDATE punks SET experience = total_experience"
      end
    end
  end
end
