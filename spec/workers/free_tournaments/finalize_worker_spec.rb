# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::FinalizeWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(FreeTournaments::Finalize).to receive(:call)

    perform
  end
end
