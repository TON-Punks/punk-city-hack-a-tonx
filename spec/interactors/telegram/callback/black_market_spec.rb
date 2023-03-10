# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Callback::BlackMarket do
  describe 'menu' do
    subject do
      described_class.call(user: user, telegram_request: telegram_request, step: 'menu', callback_arguments: callback_arguments)
    end

    let(:telegram_request) { build_telegram_callback_query(data: data) }
    let(:user) { create(:user, locale: :ru, provided_wallet: wallet) }
    let(:data) { "#black_market##menu" }
    let(:wallet) { "ABCDEFGHIJKLMOP" }
    let(:callback_arguments) { {} }

    let(:expected_media) do
      {
        "type" => "photo",
        "media" => "attach://photo",
        "caption" => "🤖 *Торговый робот* протягивает вам список товаров и цен.\nПредложение актуально в течение следующих ⌛️ 15 минут.\n\nУ вас с собой 0 💾.\n\n\u{1FAA2} *Текущий кошелек:* `ABCDE.....KLMOP`\n",
        "caption_entities" => [],
        "parse_mode" => "markdown"
      }
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:edit_message).with(hash_including(media: expected_media.to_json))

      subject
    end

    context 'when user has no wallet set' do
      let(:wallet) { ['', nil].sample }

      let(:expected_media) do
        {
          "type" => "photo",
          "media" => "attach://photo",
          "caption" => I18n.t("black_market.ask_wallet.labels.ask"),
          "caption_entities" => [],
          "parse_mode" => "markdown"
        }
      end
      let(:expected_markup) do
        {
          "inline_keyboard" => [
            [{ "text" => "🕹 Вернуться", "callback_data" => "#menu##menu:" }]
          ]
        }
      end

      specify do
        expect(TelegramApi).to receive(:edit_message)
          .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

        subject
      end
    end
  end

  describe 'save_wallet' do
    subject do
      described_class.call(user: user, telegram_request: telegram_request, step: 'save_wallet', callback_arguments: callback_arguments)
    end

    let(:telegram_request) { build_telegram_callback_query(data: data, options: options) }
    let(:message) { double(:message, text: wallet) }
    let(:user) { create(:user, locale: :ru, provided_wallet: nil) }
    let(:data) { "#black_market##save_wallet" }
    let(:wallet) { "ABCDEFGHIJKLMOPABCDEFGHIJKLMOPABCDEFGHIJKLMOPXYZ" }
    let(:options) do
      {
        message: {
          chat: {
            id: -123,
            type: 'group',
            title: 'Group title'
          },
          text: wallet
        }
      }
    end
    let(:callback_arguments) { {} }

    let(:expected_media) do
      {
        "type" => "photo",
        "media" => "attach://photo",
        "caption" => "Кошелек был успешно сохранен",
        "caption_entities" => [],
        "parse_mode" => "markdown"
      }
    end
    let(:expected_markup) do
      {
        "inline_keyboard" => [
          [{ "text" => "🕹 Вернуться", "callback_data" => "#black_market##menu:" }]
        ]
      }
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:edit_message)
        .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

      subject
    end

    context 'when wallet in invalid' do
      let(:wallet) { '' }

      let(:expected_media) do
        {
          "type" => "photo",
          "media" => "attach://photo",
          "caption" => "Неправильный формат адреса",
          "caption_entities" => [],
          "parse_mode" => "markdown"
        }
      end
      let(:expected_markup) do
        {
          "inline_keyboard" => [
            [{ "text" => "🕹 Вернуться", "callback_data" => "#menu##menu:" }]
          ]
        }
      end

      specify do
        expect(TelegramApi).to receive(:edit_message)
          .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

        subject
      end
    end
  end
end
