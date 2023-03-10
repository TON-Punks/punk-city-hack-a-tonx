# == Schema Information
#
# Table name: dao_proposals
#
#  id          :bigint           not null, primary key
#  description :text
#  expires_at  :datetime
#  has_cover   :boolean          default(FALSE), not null
#  name        :text
#  state       :integer          default("active"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  punk_id     :bigint           not null
#
# Indexes
#
#  index_dao_proposals_on_punk_id  (punk_id)
#
# Foreign Keys
#
#  fk_rails_...  (punk_id => punks.id)
#
class DaoProposal < ApplicationRecord
  include AwsHelper

  belongs_to :punk

  has_many :votes, class_name: 'DaoProposalVote'

  enum state: { active: 0, approved: 1, rejected: 2 }

  before_create :set_default_expires_at

  def self.votes_counter # Maybe a temp solution
    DaoProposalVote.group(%i[dao_proposal_id state]).count
  end

  def cover_url
    return unless has_cover

    s3_object(AwsConfig.dao_proposal_path(id)).presigned_url(:get, expires_in: 1.week.to_i)
  end

  private

  def set_default_expires_at
    self.expires_at ||= 1.week.from_now
  end
end
