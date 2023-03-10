# frozen_string_literal: true

require "rails_helper"

RSpec.describe Telegram::Notifications::ConnectedPunkStatistics do
  describe ".call" do
    subject do
      described_class.call(punks_count: punks_count, praxis_reward: praxis_reward,
        additional_punks_count: additional_punks_count)
    end

    let(:punks_count) { rand(5000) }
    let(:praxis_reward) { rand(100..1000) }
    let(:additional_punks_count) { rand(100..1000) }

    let(:expected_text) do
      I18n.t("notifications.connected_punk_bonus.statistics",
        punks_count: punks_count,
        praxis_reward: praxis_reward,
        additional_punks_count: additional_punks_count)
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: "-4", text: expected_text)
      expect(TelegramApi).to receive(:send_message).with(chat_id: "-1", text: expected_text)
      expect(TelegramApi).to receive(:send_message).with(chat_id: "-2", text: expected_text)

      subject
    end
  end
end
