# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Praxis::ConnectedPunkBonusesWorker do
  subject(:perform) { described_class.new.perform }

  let(:first_user_with_punk) { create(:user) }
  let(:second_user_with_punk) { create(:user) }
  let(:first_punk) { create(:punk) }
  let(:second_punk) { create(:punk) }

  let(:user_without_punk) { create(:user) }

  let(:first_user_connected_punk_result) { OpenStruct.new(new_rewarded_punks_ids: [first_user_with_punk.id]) }
  let(:second_user_connected_punk_result) { OpenStruct.new }

  before do
    create(:user)
    create(:punk_connection, state: :connected, user: first_user_with_punk, punk: first_punk)
    create(:punk_connection, state: :connected, user: second_user_with_punk, punk: second_punk)
    create(:punk_connection, state: :requested, user: user_without_punk, punk: second_punk)
  end

  specify do
    expect(Praxis::Bonus::ConnectedPunk).to receive(:call).with(user: first_user_with_punk, rewarded_punks_ids: [])
      .and_return(first_user_connected_punk_result)
    expect(Praxis::Bonus::ConnectedPunk).to receive(:call).with(user: second_user_with_punk, rewarded_punks_ids: [first_user_with_punk.id])
      .and_return(second_user_connected_punk_result)

    perform
  end
end
