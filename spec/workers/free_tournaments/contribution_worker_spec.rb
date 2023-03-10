# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::ContributionWorker do
  subject(:perform) { described_class.new.perform(user.id, game.id) }

  let(:user) { create(:user) }
  let(:game) { create(:rock_paper_scissors_game) }

  specify do
    expect(FreeTournaments::Contribute).to receive(:call).with(user: user, game: game)
    perform
  end
end
