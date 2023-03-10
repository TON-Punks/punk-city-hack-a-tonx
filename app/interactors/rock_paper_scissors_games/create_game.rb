class RockPaperScissorsGames::CreateGame
  include Interactor

  delegate :game, to: :context

  def call
    matching_game = find_matching_game

    if matching_game
      join_result = RockPaperScissorsGames::JoinGame.call(user: game.creator, game: matching_game)
      if join_result.success?
        context.creator_versus_image = join_result.creator_versus_image
        context.opponent_versus_image = join_result.opponent_versus_image
        context.game = join_result.game

        return context.joined = true
      end
    end

    create_game
  end

  private

  def find_matching_game
    RockPaperScissorsGame.created.public_visibility.find_by(bet: game.bet, bet_currency: game.bet_currency)
  end

  def create_game
    game.save!
    game.send_creation_notifications
    if game.public_visibility?
      RockPaperScissorsGames::JoinByBotWorker.perform_in(rand(RockPaperScissorsGame::BOT_INVOLVEMENT_RANGE[:paid]),
        game.id)
    end
  end
end
