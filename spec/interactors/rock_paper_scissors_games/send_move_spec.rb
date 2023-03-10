# frozen_string_literal: true

require 'rails_helper'

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::SendMove do
  let(:opponent_wallet) { create :wallet, :with_credential }
  %w[opponent creator].each do |user_type|
    context 'when user_type opponent' do
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
        described_class.call(game: game, dry_run: true, user_type: user_type)
      end
    end
  end
end
