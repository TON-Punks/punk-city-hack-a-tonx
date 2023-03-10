# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::NewPraxisTransaction do
  describe '.call' do
    subject { described_class.call(user: user, praxis_amount: praxis_amount, praxis_sender: praxis_sender) }

    let(:user) { create(:user) }
    let(:praxis_amount) { 200 }
    let(:praxis_sender) { 'durov' }

    let(:expected_text) do
      I18n.t("notifications.new_praxis_transaction",
             praxis_balance: user.praxis_balance,
             praxis_amount: praxis_amount,
             praxis_sender: praxis_sender
           )
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: expected_text)

      subject
    end
  end
end
