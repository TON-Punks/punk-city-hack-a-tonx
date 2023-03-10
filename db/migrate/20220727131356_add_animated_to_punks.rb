class AddAnimatedToPunks < ActiveRecord::Migration[6.1]
  def change
    add_column :punks, :animated_at, :timestamp
  end
end
