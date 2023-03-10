# == Schema Information
#
# Table name: dao_proposal_votes
#
#  id              :bigint           not null, primary key
#  state           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dao_proposal_id :bigint           not null
#  punk_id         :bigint           not null
#
# Indexes
#
#  index_dao_proposal_votes_on_dao_proposal_id              (dao_proposal_id)
#  index_dao_proposal_votes_on_punk_id_and_dao_proposal_id  (punk_id,dao_proposal_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (dao_proposal_id => dao_proposals.id)
#  fk_rails_...  (punk_id => punks.id)
#
class DaoProposalVote < ApplicationRecord
  belongs_to :punk
  belongs_to :dao_proposal

  enum state: { approved: 0, rejected: 1 }

  validates_uniqueness_of :punk, scope: :dao_proposal_id
end
