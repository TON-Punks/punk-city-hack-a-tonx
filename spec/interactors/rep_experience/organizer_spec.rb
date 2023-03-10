require 'rails_helper'

RSpec.describe RepExperience::Organizer do
  let(:interactors_list) do
    [
      RepExperience::CombotFetcher,
      RepExperience::CsvParser,
      RepExperience::BaseChangesCalculator,
      RepExperience::UsersDataProcessor,
      RepExperience::TopRewardsNotifier
    ]
  end

  specify do
    expect(described_class.new).to be_kind_of(Interactor::Organizer)
  end

  specify do
    expect(described_class.organized).to eq(interactors_list)
  end

  describe '.call' do
    subject { described_class.call }

    let!(:first_user) { create(:user, chat_id: 123, chat_rep: 7) }
    let!(:second_user) { create(:user, chat_id: 456, chat_rep: 33) }

    let(:expected_top_rewards) do
      [
        {
          exp_to_add: 56,
          rep_change: -13,
          user: second_user
        },
        {
          exp_to_add: 15,
          rep_change: 3,
          user: first_user
        }
      ]
    end

    around { |e| VCR.use_cassette("combot/chat_users", &e) }

    specify do
      expect(Telegram::Notifications::NewTopRepRewards).to receive(:call).with(score: expected_top_rewards)
      expect(Telegram::Notifications::ChatRepRewarded).to receive(:call).with(user: first_user, rep: 3, exp: 15)
      expect(Telegram::Notifications::ChatRepRewarded).to receive(:call).with(user: second_user, rep: -13, exp: 56)

      subject

      expect(first_user.reload.chat_rep).to eq(10)
      expect(second_user.reload.chat_rep).to eq(20)
    end
  end
end
