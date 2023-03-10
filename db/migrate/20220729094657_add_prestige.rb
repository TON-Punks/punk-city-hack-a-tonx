class AddPrestige < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :prestige_level, :integer, null: false, default: 0
    add_column :punks, :prestige_level, :integer, null: false, default: 0
    add_column :users, :prestige_expirience, :integer, null: false, default: 0
    add_column :punks, :prestige_expirience, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        execute "UPDATE users SET prestige_level = level, prestige_expirience = expirience"
        execute "UPDATE punks SET prestige_level = level, prestige_expirience = expirience"
      end
    end
  end
end
