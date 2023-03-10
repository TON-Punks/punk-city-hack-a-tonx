# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::RemoveNotifications do
  let(:game) { create :rock_paper_scissors_game }

  describe 'call' do
    before do
      game.notifications.create(chat_id: 123, message_id: 1, temporary: false)
      game.notifications.create(chat_id: 123, message_id: 1)
    end

    specify do
      expect(TelegramApi).to receive(:delete_message).with(chat_id: '123', message_id: '1').once

      expect { described_class.call(game: game) }.to change { game.notifications.count }.from(2).to(0)
    end
  end
end
