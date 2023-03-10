class CreateDaoProposalVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :dao_proposal_votes do |t|
      t.belongs_to :punk, null: false, foreign_key: true, index: false
      t.belongs_to :dao_proposal, null: false, foreign_key: true
      t.integer :state, null: false

      t.timestamps
    end

    add_index :dao_proposal_votes, %i[punk_id dao_proposal_id], unique: true
  end
end
