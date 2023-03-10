class AddTotalExperienceToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :total_experience, :bigint, null: false, default: 0
    add_column :punks, :total_experience, :bigint, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute "UPDATE users SET total_experience = ((level * (level + 1) / 2) * 1000 + expirience)"
        execute "UPDATE punks SET total_experience = ((level * (level + 1) / 2) * 1000 + expirience)"
      end
    end
  end
end
