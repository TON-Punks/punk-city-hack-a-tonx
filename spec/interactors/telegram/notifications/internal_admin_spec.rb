# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::InternalAdmin do
  describe '.call' do
    subject { described_class.call(admin_chat_id: chat_id, message: message) }

    let(:chat_id) { rand(10..100) }
    let(:message) { 'random_message' }

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: chat_id, text: message)

      subject
    end
  end
end
