class AddSegmentToCrmNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :crm_notifications, :segment_id, :bigint
  end
end
