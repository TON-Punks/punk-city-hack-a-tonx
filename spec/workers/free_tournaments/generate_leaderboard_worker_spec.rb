# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::GenerateLeaderboardWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(FreeTournaments::RecalculateStatistics).to receive(:call)
    expect(FreeTournaments::Leaderboard::Generate).to receive(:call)

    perform
  end
end
