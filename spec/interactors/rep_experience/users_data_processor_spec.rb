require 'rails_helper'

RSpec.describe RepExperience::UsersDataProcessor do
  subject { described_class.call(data: data) }

  let(:data) do
    [
      {
        user: user,
        rep_change: rep_change,
        exp_to_add: exp_to_add
      }
    ]
  end

  let(:user) { create(:user, chat_rep: 10, experience: 100) }
  let(:rep_change) { -3 }
  let(:exp_to_add) { 15 }

  specify do
    expect(Telegram::Notifications::ChatRepRewarded).to receive(:call).with(user: user, rep: rep_change, exp: exp_to_add)

    expect { subject }.to change(user, :experience).from(100).to(115)
    expect(user.reload.chat_rep).to eq(7)
  end
end
