# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deeplinks::Invite do
  describe '#encode' do
    let(:user_id) { 500_000_000 }

    specify do
      base64 = described_class.encode(user_id)

      expect(base64.size).to be < 64
      decoded = JSON.parse(Base64.urlsafe_decode64(base64))
      expect(decoded['type']).to eq('invite')
      expect(decoded['user_id']).to eq(user_id)
    end
  end

  describe '#consume' do
    let(:user) { create :user }
    let(:referred) { create :user }

    specify do
      referral = described_class.consume({ user_id: user.id, referred_id: referred.id })

      expect(referral.user).to eq(user)
      expect(referral.referred).to eq(referred)
    end
  end
end
