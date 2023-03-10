# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::Matchmaking::SendInvitesWorker do
  subject { described_class.new.perform }

  specify do
    expect(RockPaperScissorsGames::Matchmaking::SendInvites).to receive(:call)

    subject
  end
end
