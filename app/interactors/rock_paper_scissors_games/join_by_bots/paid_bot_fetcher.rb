class RockPaperScissorsGames::JoinByBots::PaidBotFetcher < RockPaperScissorsGames::JoinByBots::BaseBotFetcher
  include TonHelper

  MAX_TON_BET = 5
  MAX_PRAXIS_BET = 10_000
  MAX_GAMES_IN_A_ROW = 6

  delegate :game_id, to: :context

  def call
    raise_error("Game not found") if game.blank?
    validate_game_bet!

    context.bot_id = prepared_bot_id
    raise_blank_bot_id_error if context.bot_id.blank?

    context.bot_strategy = :random
  end

  private

  def validate_game_bet!
    if game.ton_bet_currency?
      validate_ton_bet!
    elsif game.praxis_bet_currency?
      validate_praxis_bet!
    end
  end

  def validate_ton_bet!
    raise_error("Ton bet (#{game.pretty_bet}) is greater than #{MAX_TON_BET}") if game.bet > to_nano(MAX_TON_BET)
  end

  def validate_praxis_bet!
    raise_error("Praxis bet (#{game.pretty_bet}) is greater than #{MAX_PRAXIS_BET}") if game.bet > MAX_PRAXIS_BET
  end

  def raise_blank_bot_id_error
    if game.ton_bet_currency?
      raise_error("Ton bet (#{game.pretty_bet}) is higher than bot's balances") if all_bot_ids_for_ton.blank?
    elsif game.praxis_bet_currency?
      raise_error("Praxis bet (#{game.pretty_bet}) is higher than bot's balances") if all_bot_ids_for_praxis.blank?
    end

    raise_error("All bots under cooldown")
  end

  def prepared_bot_id
    @prepared_bot_id ||= recent_bot_id.present? ? recent_bot_id : (bots_ids - bots_ids_under_cooldown).sample
  end

  def recent_bot_id
    @recent_bot_id ||= recently_played_games_count.detect do |_bot_id, games_count|
      games_count.positive? && games_count < MAX_GAMES_IN_A_ROW
    end&.first
  end

  def bots_ids_under_cooldown
    @bots_ids_under_cooldown ||= recently_played_games_count.select do |_bot_id, games_count|
      games_count > MAX_GAMES_IN_A_ROW
    end.keys
  end

  def recently_played_games_count
    @recently_played_games_count ||= paid_bots_games.where(created_at: 2.hours.ago.., opponent_id: bots_ids)
                                                    .group(:opponent_id)
                                                    .count
                                                    .to_a
                                                    .shuffle
                                                    .to_h
  end

  def game
    @game ||= RockPaperScissorsGame.find_by(id: game_id)
  end

  def bots_ids
    @bots_ids ||= (all_bot_ids - unavailable_bot_ids).shuffle
  end

  def unavailable_bot_ids
    paid_bots_games.where(created_at: Time.now.utc.beginning_of_day.., opponent_id: all_bot_ids)
                   .group(:opponent_id)
                   .having("count(*) > 20")
                   .count
                   .keys
  end

  def paid_bots_games
    RockPaperScissorsGame.with_bet.where(bot: true)
  end

  def all_bot_ids
    if game.ton_bet_currency?
      all_bot_ids_for_ton
    elsif game.praxis_bet_currency?
      all_bot_ids_for_praxis
    else
      context.fail!
    end
  end

  def all_bot_ids_for_ton
    @all_bot_ids_for_ton ||= Wallet.where(Wallet.arel_table[:virtual_balance].gteq(game.bet))
                                   .where(user_id: TelegramConfig.bot_ids)
                                   .pluck(:user_id)
  end

  def all_bot_ids_for_praxis
    TelegramConfig.bot_ids.select { |id| User.find_by(id: id)&.praxis_wallet&.balance.to_i >= game.bet }
  end

  def raise_error(error)
    context.fail!(error: error)
  end
end
