# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::ConnectedPunkStatisticsWorker do
  subject(:perform) { described_class.new.perform }

  let(:connected_punks_count) { 2 }
  let(:weekly_praxis_rewards_amount) { 700 }

  let!(:first_punk_connection) { create(:punk_connection, state: :connected) }
  let!(:second_punk_connection) { create(:punk_connection, state: :connected) }

  before do
    create(:punk, owner: first_punk_connection.punk.owner)
    create(:punk_connection, state: :disconnected).punk.update(owner: 'another')
    create(:praxis_transaction, operation_type: PraxisTransaction::CONNECTED_PUNK_BONUS, created_at: 1.day.ago, quantity: 200)
    create(:praxis_transaction, operation_type: PraxisTransaction::CONNECTED_PUNK_BONUS, created_at: 4.days.ago, quantity: 500)
    create(:praxis_transaction, operation_type: PraxisTransaction::CONNECTED_PUNK_BONUS, created_at: 10.days.ago, quantity: 100)
  end

  specify do
    expect(Telegram::Notifications::ConnectedPunkStatistics).to receive(:call).with(
      punks_count: connected_punks_count,
      additional_punks_count: 1,
      praxis_reward: weekly_praxis_rewards_amount
    )

    perform
  end
end
