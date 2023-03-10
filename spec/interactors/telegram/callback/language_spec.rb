# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Callback::Language do
  let(:telegram_request) { build_telegram_callback_query(data: data) }
  let(:user) { create(:user, locale: nil) }
  let(:data) { "#language###{step}" }

  subject(:call) do
    described_class.call(user: user, telegram_request: telegram_request, step: step, callback_arguments: callback_arguments)
  end

  describe 'menu' do
    let(:step) { 'menu' }
    let(:callback_arguments) { {} }

    let(:expected_media) do
      {
        "type" => "photo",
        "media" => "attach://photo",
        "caption" =>
        "🈳 Choose your language",
        "caption_entities" => [],
        "parse_mode" => "markdown"
      }
    end
    let(:expected_markup) do
      {
        "inline_keyboard" =>
        [
          [
            { "text" => "🇷🇺 Русский", "callback_data" => "#language##set_language:language=ru" },
            { "text" => "🇬🇧 English", "callback_data" => "#language##set_language:language=en" }
          ]
        ]
      }
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:edit_message)
        .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

      call
    end

    context 'when user has locale set' do
      let(:user) { create(:user, locale: 'ru') }

      let(:expected_markup) do
        {
          "inline_keyboard" =>
          [
            [
              {"text"=>"🇷🇺 Русский", "callback_data"=>"#language##set_language:language=ru"},
              {"text"=>"🇬🇧 English", "callback_data"=>"#language##set_language:language=en"}
            ],
            [
              {"text"=>"🕹 Вернуться", "callback_data"=>"#profile##menu:"}
            ]
          ]
        }
      end

      specify do
        expect(TelegramApi).to receive(:edit_message)
          .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

        call
      end
    end
  end

  describe 'set_language' do
    let(:user) { create(:user, locale: 'en', onboarded: true) }
    let(:step) { 'set_language' }
    let(:callback_arguments) { { "language" => language } }
    let(:language) { 'ru' }

    let(:expected_media) do
      {
        "type" => "photo",
        "media" => "attach://photo",
        "caption" => "✅ Готово",
        "caption_entities" => [],
        "parse_mode" => "markdown"
      }
    end
    let(:expected_markup) do
      {
        "inline_keyboard" => [
          [
            { "text" => "🕹 Вернуться", "callback_data" => "#profile##menu:" }
          ]
        ]
      }
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:edit_message)
        .with(hash_including(media: expected_media.to_json, reply_markup: expected_markup.to_json))

      call

      expect(user.reload.locale).to eq(language)
    end

    context 'when user is not onboarded' do
      let(:user) { create(:user, onboarded: false) }

      it do
        expect(Telegram::Callback::Onboarding).to receive(:call)
          .with(user: user, telegram_request: telegram_request, step: 'step1')

        call

        expect(user.reload.locale).to eq(language)
      end
    end
  end
end
