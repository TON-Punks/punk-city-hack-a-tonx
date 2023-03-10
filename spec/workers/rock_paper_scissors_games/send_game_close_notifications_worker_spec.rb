# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::SendGameCloseNotificationsWorker do
  let(:game) { create(:rock_paper_scissors_game, :with_opponent, state: %w[creator_won opponent_won archived].sample) }

  specify do
    expect(Telegram::Notifications::GameClose).to receive(:call).with(
      free_game: game.free?,
      user: game.creator,
      user_escaped: game.archived? || game.opponent_won?
    )
    expect(Telegram::Notifications::GameClose).to receive(:call).with(
      free_game: game.free?,
      user: game.opponent,
      user_escaped: game.archived? || game.creator_won?
    )

    described_class.new.perform(game.id)
  end
end
