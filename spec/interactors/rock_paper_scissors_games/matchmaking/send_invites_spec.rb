# frozen_string_literal: true

require "rails_helper"

RSpec.describe RockPaperScissorsGames::Matchmaking::SendInvites do
  subject { described_class.call }

  let(:first_game) { create(:rock_paper_scissors_game, state: :created, bet: 10, bet_currency: :ton) }
  let(:new_game) { create(:rock_paper_scissors_game, state: :created, bet: new_game_bet, bet_currency: :ton) }
  let(:first_message_id) { 123 }
  let(:new_message_id) { 345 }
  let(:search_message_storage) { RockPaperScissorsGames::Matchmaking::SearchMessageStorage.new }

  context "when new game has higher bet" do
    let(:new_game_bet) { 11 }

    before do
      search_message_storage.set(first_game.id, first_message_id)
      search_message_storage.set(new_game.id, new_message_id)
    end

    it "send invite to higher bet game" do
      expect(Telegram::Callback::Arena::TonBattle).to receive(:call).with(
        user: new_game.creator,
        callback_arguments: { game: new_game, proposed_game: first_game }.with_indifferent_access,
        telegram_request: search_message_storage.telegram_request_for(new_game.id),
        step: :wait_with_proposed_game
      )

      expect(Telegram::Callback::Arena::TonBattle).to receive(:call).with(
        user: first_game.creator,
        callback_arguments: { game: first_game }.with_indifferent_access,
        telegram_request: search_message_storage.telegram_request_for(first_game.id),
        step: :wait_for_game
      )

      subject
    end
  end

  context "when new game has lower bet" do
    let(:new_game_bet) { 3 }

    it "invites already created game" do
      expect(Telegram::Callback::Arena::TonBattle).to receive(:call).with(
        user: first_game.creator,
        callback_arguments: { game: first_game, proposed_game: new_game }.with_indifferent_access,
        telegram_request: search_message_storage.telegram_request_for(first_game.id),
        step: :wait_with_proposed_game
      )

      expect(Telegram::Callback::Arena::TonBattle).to receive(:call).with(
        user: new_game.creator,
        callback_arguments: { game: new_game }.with_indifferent_access,
        telegram_request: search_message_storage.telegram_request_for(new_game.id),
        step: :wait_for_game
      )

      subject
    end
  end
end
