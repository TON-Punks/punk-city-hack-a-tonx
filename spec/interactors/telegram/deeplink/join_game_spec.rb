# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Deeplink::JoinGame do
  describe 'call' do
    let(:game) { create :rock_paper_scissors_game }
    let(:user) { create :user }

    context 'when success' do
      specify do
        expect(Telegram::Callback::Fight).to receive(:call).exactly(2).times

        described_class.call(deeplink_arguments: {game_id: game.id }, user: user)
      end

      context 'when not onboarded user' do
        let(:user) { create :user }

        specify do
          expect(Telegram::Callback::Fight).to receive(:call).exactly(2).times

          described_class.call(deeplink_arguments: {game_id: game.id }, user: user)
          expect(user.reload.referred_by).to eq(game.creator)
        end
      end
    end

    context 'when already joined' do
      before do
        game.update(opponent: create(:user))
        stub_telegram
      end

      specify 'failure' do
        user.update(onboarded: true)
        expect(Telegram::Callback::Menu).to receive(:call)

        described_class.call(deeplink_arguments: {game_id: game.id }, user: user)
        expect(Referral.count).to eq(0)
      end
    end
  end
end
