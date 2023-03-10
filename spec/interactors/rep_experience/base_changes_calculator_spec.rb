require 'rails_helper'

RSpec.describe RepExperience::BaseChangesCalculator do
  subject { described_class.call(data: data) }

  let(:data) do
    [
      { chat_id: '123', name: 'First', rep: 10 },
      { chat_id: '456', name: 'Second', rep: 15 },
      { chat_id: '789', name: 'Third', rep: 20 },
      { chat_id: '000000', name: 'Unknown', rep: 200 }
    ]
  end

  let(:first_chat_id) { '123' }
  let(:second_chat_id) { '456' }
  let(:third_chat_id) { '789' }

  let!(:first_user) { create(:user, chat_id: first_chat_id, chat_rep: -10) }
  let!(:second_user) { create(:user, chat_id: second_chat_id, chat_rep: 40) }
  let!(:third_user) { create(:user, chat_id: third_chat_id, chat_rep: 20) }

  let(:expected_result) do
    [
      { user: first_user, rep_change: 20, exp_to_add: 70 },
      { user: second_user, rep_change: -25, exp_to_add: 80 },
    ]
  end

  specify do
    expect(subject.data).to eq(expected_result)
  end
end
