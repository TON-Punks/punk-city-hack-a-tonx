class AddHasCoverToDaoProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :dao_proposals, :has_cover, :boolean, default: false, null: false
  end
end
