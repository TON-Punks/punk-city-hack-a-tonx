class CreateCrmNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :crm_notifications do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :crm_type

      t.timestamps
    end
  end
end
