class CreatePunks < ActiveRecord::Migration[6.1]
  def change
    create_table :punks do |t|
      t.string :address, index: true
      t.string :base64_address, index: true
      t.string :owner, index: true
      t.string :number
      t.string :image_url
      t.bigint :expirience, null: false, default: 0
      t.integer :level, null: false, default: 0

      t.timestamps
    end
  end
end
