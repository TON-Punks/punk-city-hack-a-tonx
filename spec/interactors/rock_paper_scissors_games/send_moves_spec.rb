# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::SendMoves do
  let(:opponent_wallet) { create :wallet, :with_credential }
  let(:creator_wallet) { create :wallet, :with_credential }
  let(:game) do
    create :rock_paper_scissors_game,
      creator: creator_wallet.user,
      opponent: opponent_wallet.user,
      bet: 100_000_000,
      address: ContractsConfig.manager_address
  end

  before do
    create_list :game_round, 3, rock_paper_scissors_game: game, winner_damage: 15, winner: :opponent
    create :game_round, rock_paper_scissors_game: game, winner: :opponent, opponent: nil
  end

  specify do
    expect(RockPaperScissorsGames::ValidateCompletenessWorker).to receive(:perform_in)
    expect(RockPaperScissorsGames::SendMove).to receive(:call).twice.and_call_original

    described_class.call(game: game, dry_run: true)
  end
end
