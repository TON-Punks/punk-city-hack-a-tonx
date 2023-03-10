# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DaoProposalVotesController do
  let(:punk) { create(:punk_connection, :connected).punk }
  let(:dao_proposal) { create :dao_proposal, punk: punk }

  describe '#index' do
    before do
      create :dao_proposal_vote, state: :rejected, dao_proposal: dao_proposal
      create_list :dao_proposal_vote, 2, state: :approved, dao_proposal: dao_proposal
    end

    specify do
      get :index, params: { dao_proposal_id: dao_proposal.id }

      json_body = JSON.parse(response.body)
      expect(json_body.size).to eq(3)
    end

    context 'with filter' do
      specify do
        get :index, params: { dao_proposal_id: dao_proposal.id, filter: :approved }

        json_body = JSON.parse(response.body)
        expect(json_body.size).to eq(2)
      end
    end
  end

  describe '#create' do
    specify do
      expect {
        post :create, params: { vote: { state: :approved }, dao_proposal_id: dao_proposal.id }
      }.to change {
        DaoProposal.count
      }.by(1)
    end

    context 'when vote was already cast' do
      before do
        create :dao_proposal_vote, dao_proposal: dao_proposal, punk: punk, state: :approved
      end

      specify do
        post :create, params: { vote: { state: :approved }, dao_proposal_id: dao_proposal.id }

        expect(response.status).to eq(422)
      end
    end
  end
end
