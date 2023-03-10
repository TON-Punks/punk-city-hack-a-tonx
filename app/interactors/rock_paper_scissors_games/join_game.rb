class RockPaperScissorsGames::JoinGame
  include Interactor
  include RedisHelper

  delegate :game_id, :user, :game, :bot, :bot_strategy, to: :context

  def call
    with_lock "game_join-#{game_id}" do |locked|
      return already_started! unless locked

      context.game ||= RockPaperScissorsGame.find_by(id: game_id)
      return not_found! if game.blank?
      return archive! unless game.created?
      return already_started! if game.opponent.present?
      return own_game! if game.creator == user
      return game_creator_in_another_battle! if creator_in_another_battle?

      validate_user_balance!
      return too_many_leaves! if game.free? && user.leave_penalty?

      game.update!(opponent: user, bot: game.bot || !!bot, bot_strategy: game.bot_strategy || bot_strategy)
      game.start!

      unless game.free?
        result = RockPaperScissorsGames::CreateVersusImage.call(game: game)
        context.creator_versus_image = result.creator_output_path
        context.opponent_versus_image = result.opponent_output_path
      end
    end
  end

  private

  def validate_user_balance!
    return if game.free?

    if game.ton_bet_currency?
      validate_ton_balance!
    elsif game.praxis_bet_currency?
      validate_praxis_balance!
    end
  end

  def creator_in_another_battle?
    game.creator.created_rock_paper_scissors_games.started.any? ||
      game.creator.participated_rock_paper_scissors_games.started.any?
  end

  def validate_ton_balance!
    not_enough_money! if game.bet > user.wallet&.virtual_balance.to_i
  end

  def validate_praxis_balance!
    not_enough_money! if game.bet > user.praxis_wallet&.balance
  end

  def not_found!
    context.fail!(error: I18n.t("notifications.join_game.errors.game_not_found"), redirect: false)
  end

  def too_many_leaves!
    context.fail!(error: I18n.t("cyber_arena.errors.too_many_leaves", seconds: Users::GameLeavePenalty.new(user).ttl),
      redirect: false)
  end

  def archive!
    context.fail!(error: I18n.t("notifications.join_game.errors.game_not_active"), redirect: true)
  end

  def game_creator_in_another_battle!
    context.fail!(error: I18n.t("notifications.join_game.errors.game_creator_another_battle"), redirect: true)
  end

  def already_started!
    context.fail!(error: I18n.t("notifications.join_game.errors.game_already_started"), redirect: true)
  end

  def not_enough_money!
    context.fail!(
      error: I18n.t("notifications.join_game.errors.not_enough_#{game.bet_currency}",
        wallet_adress: user.wallet.pretty_address), redirect: true
    )
  end

  def own_game!
    context.fail!(redirect: false)
  end
end
