# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::RegularExchangeCompleted do
  describe '.call' do
    subject { described_class.call(user: user, praxis: praxis) }

    let(:user) { create(:user, locale: :ru) }
    let(:praxis) { rand(1..100) }

    let(:expected_text) { "БАНК: Ваша заявка на получение Праксиса 💾 была исполнена." }

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: expected_text)

      subject
    end
  end
end
