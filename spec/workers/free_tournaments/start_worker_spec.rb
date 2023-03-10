# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::StartWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(FreeTournaments::Create).to receive(:call)

    perform
  end
end
