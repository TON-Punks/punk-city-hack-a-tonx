require "rails_helper"

RSpec.describe FreeTournaments::Leaderboard::StatisticsData do
  describe ".call" do
    subject { described_class.call(page: 0, tournament: tournament) }

    let(:tournament) { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now) }
    let(:first_user) { create(:user, username: nil, chat_id: 123) }
    let(:second_user) { create(:user, username: nil, first_name: "George", last_name: "Lozovsky") }

    let(:expected_leaderboard) do
      [
        {
          games_lost: 12,
          games_won: 13,
          position: 3,
          reward: 5,
          score: 10,
          username: "ANON #123"
        },
        {
          games_lost: 3,
          games_won: 5,
          position: 5,
          reward: 2,
          score: 1,
          username: "George Lozo…"
        }
      ]
    end

    before do
      tournament.statistic_for_user(first_user).update(score: 10, position: 3, reward: 5, games_won: 13, games_lost: 12)
      tournament.statistic_for_user(second_user).update(score: 1, position: 5, reward: 2, games_won: 5, games_lost: 3)
    end

    specify do
      expect(subject.last_page).to be_truthy
      expect(subject.leaderboard).to eq(expected_leaderboard)
    end
  end
end
