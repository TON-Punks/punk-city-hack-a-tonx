# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::DecreaseWeaponsDurability do
  describe '#call' do
    let(:creator) { create :user, :with_weapons }
    let(:opponent) { create :user, :with_default_weapons }
    let(:game) { create :rock_paper_scissors_game, creator: creator, opponent: opponent }

    before { game.cache_weapons }

    context "when weapon isn't breaking" do
      before do
        creator.items_users.each(&:initialize_durability).each(&:save!)
      end

      specify do
        expect(TelegramApi).to receive(:send_message)
        described_class.call(game: game)

        expect(creator.items_users.reload.map(&:current_durability).uniq.first).to eq(59)
        expect(creator.items_users.not_disabled.count).to eq(5)
      end
    end

    context 'when weapon is breaking' do
      before do
        creator.items_users.each do |items_user|
          items_user.current_durability = 1
          items_user.save!
        end
      end

      specify do
        expect(TelegramApi).to receive(:send_message)
        described_class.call(game: game)

        expect(creator.items_users.not_disabled).to be_empty
      end
    end
  end
end
