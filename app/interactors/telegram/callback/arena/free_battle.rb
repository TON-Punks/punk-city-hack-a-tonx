class Telegram::Callback::Arena::FreeBattle < Telegram::Callback::Arena::Base
  include TonHelper

  delegate :wallet, to: :user

  def menu
    with_lock "starting-free-game-#{user.id}" do |locked|
      return unless locked
      return send_message(I18n.t("cyber_arena.errors.hit_limit")) if RockPaperScissorsGames::FreeGamesCounter.hit_limit?

      started_game = user.created_rock_paper_scissors_games.free.started.first
      return send_message(I18n.t("cyber_arena.errors.single_free_game")) if started_game

      waiting_game = user.created_rock_paper_scissors_games.free.created.first
      return wait_for_game(waiting_game) if waiting_game

      return send_message(I18n.t("cyber_arena.errors.cant_start_game")) unless user.can_start_new_game?

      if user.leave_penalty?
        return send_message(I18n.t("cyber_arena.errors.too_many_leaves",
          seconds: Users::GameLeavePenalty.new(user).ttl))
      end

      if (game_id = RockPaperScissorsGames::Queue.pop)
        game = RockPaperScissorsGame.find_by(id: game_id)
        return menu if game.blank? || !game.created?

        unless RockPaperScissorsGames::FreeGamesMatchmaking.can_be_matched?(game.creator, user)
          RockPaperScissorsGames::Queue.push(game_id)
          game = create_free_game!(user)
          return wait_for_game(game)
        end

        game.update!(opponent: user)
        game.start!
        Telegram::Callback::Fight.call(user: user, game: game, telegram_request: telegram_request, step: :new_game)
        Telegram::Callback::Fight.call(user: game.creator, game: game, step: :new_game)
      else
        game = create_free_game!(user)

        wait_for_game(game)
      end
    end
  end

  private

  def create_free_game!(user)
    RockPaperScissorsGame.create!(creator: user).tap do |game|
      RockPaperScissorsGames::Queue.push(game.id)
      RockPaperScissorsGames::JoinByBotWorker.perform_in(rand(RockPaperScissorsGame::BOT_INVOLVEMENT_RANGE[:free]),
        game.id)
    end
  end

  def wait_for_game_type_message(_game)
    I18n.t("cyber_arena.wait_for_game.free_battle")
  end

  def wait_for_game_default_buttons(game_id)
    [
      TelegramButton.new(
        text: I18n.t("cyber_arena.wait_for_game.cancel_search"),
        data: action_data("cancel_search:game_id=#{game_id}")
      )
    ]
  end
end
