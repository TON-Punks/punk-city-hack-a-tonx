# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DaoProposalsController do
  describe '#index' do
    before { create_list :dao_proposal, 2 }

    specify do
      get :index

      json_body = JSON.parse(response.body)
      expect(json_body.size).to eq(2)
    end
  end

  describe '#create' do
    let(:punk_connection) { create :punk_connection, :connected }
    let(:user) { punk_connection.user }

    let(:cover) do
      Rack::Test::UploadedFile.new(File.join(Rails.root, 'telegram_assets', 'images', 'profile', 'ton.png'))
    end

    before do
      stub_request(:put, Regexp.new("https://punk-metaverse.fra1.digitaloceanspaces.com/dao_proposals/*"))
    end

    specify do
      post :create, params: { token: user.auth_token, dao_proposal: { name: "Name", description: "Descrition", cover: cover } }

      json_body = JSON.parse(response.body)
      %w[id created_at creator description expires_at name state cover].each do |attribute|
        expect(json_body[attribute]).to be_present
      end
    end
  end

  describe '#show' do
    let(:proposal) { create :dao_proposal }
    before do
      create_list :dao_proposal_vote, 2, dao_proposal: proposal, state: :rejected
      create_list :dao_proposal_vote, 3, dao_proposal: proposal, state: :approved
    end

    specify do
      get :show, params: { id: proposal.id }

      json_body = JSON.parse(response.body)
      %w[id created_at creator description expires_at name state].each do |attribute|
        expect(json_body[attribute]).to be_present
      end

      %w[votes_approved votes_rejected].each do |attribute|
        expect(json_body[attribute]).to be > 0
      end
    end
  end
end
