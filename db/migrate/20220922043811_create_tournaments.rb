class CreateTournaments < ActiveRecord::Migration[6.1]
  def change
    create_table :tournaments do |t|
      t.timestamp :finishes_at

      t.timestamps
    end
  end
end
