class RockPaperScissorsGames::FreeGamesMatchmaking
  MIN_BATTLES = 10
  MIN_WINRATE_THRESHOLD = 0.3
  MAX_WINRATE_THRESHOLD = 0.7
  STATS_DURATION = 1.week

  class << self
    def can_be_matched?(game_creator, user)
      creator_wons = counted_stats(game_creator.created_rock_paper_scissors_games.creator_won.where(opponent: user)) +
                     counted_stats(user.created_rock_paper_scissors_games.opponent_won.where(opponent: game_creator))

      total_battles = counted_stats(game_creator.created_rock_paper_scissors_games.where(opponent: user)) +
                      counted_stats(user.created_rock_paper_scissors_games.where(opponent: game_creator))
      return true if total_battles < MIN_BATTLES

      (creator_wons.to_f / total_battles).between?(MIN_WINRATE_THRESHOLD, MAX_WINRATE_THRESHOLD)
    end

    private

    def counted_stats(relation)
      relation.where(created_at: STATS_DURATION.ago..).count
    end
  end
end
