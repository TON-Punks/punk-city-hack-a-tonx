# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::CleanNotificationsWorker do
  subject { described_class.new.perform }

  let(:first_game) { create(:rock_paper_scissors_game, state: 'archived', updated_at: 2.hours.ago) }
  let(:second_game) { create(:rock_paper_scissors_game, state: 'creator_won', updated_at: 10.minutes.ago) }
  let(:third_game) { create(:rock_paper_scissors_game, state: 'opponent_won', updated_at: 3.hours.ago) }
  let(:fourth_game) { create(:rock_paper_scissors_game, state: 'created') }

  before do
    create(:rock_paper_scissors_notification, rock_paper_scissors_game: first_game)
    create(:rock_paper_scissors_notification, rock_paper_scissors_game: third_game)
  end

  specify do
    expect(RockPaperScissorsGames::RemoveNotificationsWorker).to receive(:perform_async).with(first_game.id)
    expect(RockPaperScissorsGames::RemoveNotificationsWorker).to receive(:perform_async).with(third_game.id)
    expect(RockPaperScissorsGames::RemoveNotificationsWorker).not_to receive(:perform_async).with(second_game.id)
    expect(RockPaperScissorsGames::RemoveNotificationsWorker).not_to receive(:perform_async).with(fourth_game.id)

    subject
  end
end
