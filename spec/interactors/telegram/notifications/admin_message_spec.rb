# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::AdminMessage do
  describe '.call' do
    subject { described_class.call(user: user, message: message) }

    let(:user) { create(:user) }
    let(:message) { 'random_message' }

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: message)

      subject
    end
  end
end
