require 'rails_helper'

RSpec.describe Telegram::Notifications::ConnectedPunkBonus do
  describe '.call' do
    subject do
      described_class.call(
        user: user,
        connected_days: connected_days,
        praxis_reward: praxis_reward,
        exp_reward: exp_reward,
        additional_punks_count: additional_punks_count,
        additional_praxis_reward: additional_praxis_reward,
        additional_exp_reward: additional_exp_reward
      )
    end

    let(:connected_days) { 10 }
    let(:praxis_reward) { 5 }
    let(:additional_praxis_reward) { 0 }
    let(:additional_punks_count) { 0 }
    let(:additional_exp_reward) { 0 }
    let(:exp_reward) { 100 }

    let(:user) { create(:user, chat_id: '777') }

    let(:expected_text) do
      I18n.t("notifications.connected_punk_bonus.reward",
        connected_days: "10 дней",
        praxis_reward: praxis_reward,
        exp_reward: exp_reward,
        additional_reward: ''
      )
    end

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: expected_text)

      subject
    end

    context 'when additional punks reward present' do
      let(:connected_days) { 4 }
      let(:additional_punks_count) { 2 }
      let(:additional_praxis_reward) { 10 }
      let(:additional_exp_reward) { 15 }
      let(:additional_reward_text) do
        I18n.t("notifications.connected_punk_bonus.additional_punks_reward",
          punks_count: additional_punks_count,
          praxis_reward: additional_praxis_reward,
          exp_reward: additional_exp_reward
        )
      end
      let(:expected_text) do
        I18n.t("notifications.connected_punk_bonus.reward",
          connected_days: "4 дня",
          praxis_reward: praxis_reward,
          exp_reward: exp_reward,
          additional_reward: additional_reward_text
        )
      end

      specify do
        expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: expected_text)

        subject
      end
    end
  end
end
