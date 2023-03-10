class AddAnimationRequestAtToPunks < ActiveRecord::Migration[6.1]
  def change
    add_column :punks, :animation_requested_at, :timestamp
  end
end
