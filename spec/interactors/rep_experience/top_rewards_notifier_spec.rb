require 'rails_helper'

RSpec.describe RepExperience::TopRewardsNotifier do
  subject { described_class.call(data: calculated_data) }

  let(:parsed_data) do
    [{ chat_id: '123', name: 'GG Master', rep: 10 }, { chat_id: '456', name: 'Bogdanoff', rep: 20 }]
  end

  let(:calculated_data) { RepExperience::BaseChangesCalculator.call(data: parsed_data).data }

  let!(:first_user) { create(:user, chat_id: 123, chat_rep: 3) }
  let!(:second_user) { create(:user, chat_id: 456, chat_rep: 33) }

  let(:expected_top_rewards) do
    [
      {
        exp_to_add: 56,
        rep_change: -13,
        user: second_user
      },
      {
        exp_to_add: 35,
        rep_change: 7,
        user: first_user
      }
    ]
  end

  specify do
    expect(TelegramApi).to receive(:send_message).exactly(1).times
    expect(Telegram::Notifications::NewTopRepRewards).to receive(:call).with(score: expected_top_rewards).and_call_original

    subject
  end
end
