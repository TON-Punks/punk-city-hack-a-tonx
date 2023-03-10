class RockPaperScissorsGames::SendGameCloseNotificationsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'high'

  def perform(game_id)
    game = RockPaperScissorsGame.find(game_id)

    Telegram::Notifications::GameClose.call(
      free_game: game.free?,
      user: game.creator,
      user_escaped: game.archived? || game.opponent_won?
    )

    if game.opponent
      Telegram::Notifications::GameClose.call(
        free_game: game.free?,
        user: game.opponent,
        user_escaped: game.archived? || game.creator_won?
      )
    end
  end
end
