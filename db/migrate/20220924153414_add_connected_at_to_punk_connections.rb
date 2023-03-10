class AddConnectedAtToPunkConnections < ActiveRecord::Migration[6.1]
  class PunkConnectionStub < ApplicationRecord
    self.table_name = :punk_connections
  end

  def change
    add_column :punk_connections, :connected_at, :datetime

    reversible do |dir|
      dir.up do
        PunkConnectionStub.where(state: 1).update_all(connected_at: Time.zone.now)
      end
    end
  end
end
