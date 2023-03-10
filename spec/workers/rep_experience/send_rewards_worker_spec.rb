require 'rails_helper'

RSpec.describe RepExperience::SendRewardsWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(RepExperience::Organizer).to receive(:call)

    perform
  end
end
