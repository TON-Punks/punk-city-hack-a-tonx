# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::DeployGame do
  let(:opponent_wallet) { create :wallet }
  let(:creator_wallet) { create :wallet }
  let(:game) { create :rock_paper_scissors_game, creator: creator_wallet.user, opponent: opponent_wallet.user, id: 120 }

  specify do
    described_class.call(game: game, dry_run: true)

    expect(game.reload.address).to eq('EQAGSZQ2SOY_vgIBC8USYstVI4yfGwvKQSMBFE9qwHKH4t5E')
  end
end
