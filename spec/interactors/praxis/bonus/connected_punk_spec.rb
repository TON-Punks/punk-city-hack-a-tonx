# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::Bonus::ConnectedPunk do
  subject { described_class.call(user: user, rewarded_punks_ids: rewarded_punks_ids) }

  let(:user) { create(:user, experience: 0) }
  let(:punk) { create(:punk, owner: 'owner', experience: 0) }
  let(:rewarded_punks_ids) { [] }

  let!(:punk_connection) { create(:punk_connection, state: :connected, user: user, punk: punk, connected_at: connected_at) }

  context 'when punk is already rewarded' do
    let(:rewarded_punks_ids) { [user.punk.id] }
    let(:connected_at) { 1.month.ago }

    specify do
      expect(Telegram::Notifications::ConnectedPunkBonus).not_to receive(:call)
      expect { subject }.not_to change(PraxisTransaction, :count)
      expect(user.actor.reload.experience).to be_zero
    end
  end

  context 'when days since connected is not zero' do
    let(:connected_at) { 1.day.ago }

    let(:expected_days_since_connected) { 1 }
    let(:expected_current_day_reward) { 5 }
    let(:expected_additional_praxis_reward) { 0 }
    let(:expected_additional_punks_count) { 0 }
    let(:expected_additional_exp_reward) { 0 }

    before do
      allow(Telegram::Notifications::ConnectedPunkBonus).to receive(:call).with(
        user: user,
        connected_days: expected_days_since_connected,
        praxis_reward: expected_current_day_reward,
        exp_reward: described_class::BASE_EXP_REWARD,
        additional_punks_count: expected_additional_punks_count,
        additional_praxis_reward: expected_additional_praxis_reward,
        additional_exp_reward: expected_additional_exp_reward
      )
    end

    context 'when user has only 1 punk connected' do
      specify do
        expect(Telegram::Notifications::ConnectedPunkBonus).to receive(:call).with(
          user: user,
          connected_days: expected_days_since_connected,
          praxis_reward: expected_current_day_reward,
          exp_reward: described_class::BASE_EXP_REWARD,
          additional_punks_count: expected_additional_punks_count,
          additional_praxis_reward: expected_additional_praxis_reward,
          additional_exp_reward: expected_additional_exp_reward
        )

        subject

        expect(user.praxis_balance).to eq(expected_current_day_reward)
        expect(user.actor.reload.experience).to eq(300)
      end
    end

    context 'when user has 3 punks on the same wallet' do
      before do
        create(:punk, owner: 'owner')
        create(:punk, owner: 'owner')
      end

      let(:connected_at) { 4.days.ago }

      let(:expected_days_since_connected) { 4 }
      let(:expected_current_day_reward) { 6 }
      let(:expected_additional_praxis_reward) { 10 }
      let(:expected_additional_punks_count) { 2 }
      let(:expected_additional_exp_reward) { 60 }

      specify do
        expect(Telegram::Notifications::ConnectedPunkBonus).to receive(:call).with(
          user: user,
          connected_days: expected_days_since_connected,
          praxis_reward: expected_current_day_reward,
          exp_reward: described_class::BASE_EXP_REWARD,
          additional_punks_count: expected_additional_punks_count,
          additional_praxis_reward: expected_additional_praxis_reward,
          additional_exp_reward: expected_additional_exp_reward
        )

        subject

        expect(user.praxis_balance).to eq(expected_current_day_reward + expected_additional_praxis_reward)
        expect(user.actor.reload.experience).to eq(360)
      end
    end
  end

  context 'when days since connected is zero' do
    let(:connected_at) { Time.zone.now }

    specify do
      expect(Telegram::Notifications::ConnectedPunkBonus).not_to receive(:call)
      expect { subject }.not_to change(PraxisTransaction, :count)
      expect(user.actor.reload.experience).to be_zero
    end
  end
end
