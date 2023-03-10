# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::GameClose do
  describe '.call' do
    subject { described_class.call(user: user, free_game: free_game, user_escaped: user_escaped) }

    let(:user) { create(:user, locale: :ru) }
    let(:free_game) { true }
    let(:user_escaped) { false }

    let(:expected_markup) do
      {
        "inline_keyboard" =>
        [
          [
            {
              "text" => "⚔️ Начать новый бой",
              "callback_data"=>"#cyber_arena##menu:"
            }
          ],
          [
            {
              "text" => "🕹 Покинуть киберарену",
              "callback_data"=>"#menu##menu:"
            }
          ]
        ]
      }
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_photo).with(hash_including(reply_markup: expected_markup.to_json))

      subject
    end

    context 'when user escaped' do
      let(:user_escaped) { true }

      specify do
        expect(TelegramApi).to receive(:send_photo).with(hash_including(caption: I18n.t("notifications.close_game.escape_replica", minutes: 1.5)))

        subject
      end
    end
  end
end
