# == Schema Information
#
# Table name: rock_paper_scissors_games
#
#  id                  :bigint           not null, primary key
#  address             :string
#  bet                 :bigint           default(0), not null
#  bet_currency        :integer
#  blockchain_state    :integer
#  boss                :text
#  bot                 :boolean          default(FALSE), not null
#  bot_strategy        :string
#  creator_experience  :integer
#  current_weapons     :json             not null
#  opponent_experience :integer
#  rounds              :jsonb            not null
#  state               :integer          default("created"), not null
#  visibility          :integer          default("public"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :bigint           not null
#  opponent_id         :bigint
#
# Indexes
#
#  index_rock_paper_scissors_games_on_creator_id   (creator_id)
#  index_rock_paper_scissors_games_on_opponent_id  (opponent_id)
#  index_rock_paper_scissors_games_on_state        (state)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (opponent_id => users.id)
#
class RockPaperScissorsGame < ApplicationRecord
  include TonHelper
  extend RedisHelper
  include AASM

  MIN_TON_BET = 500000000
  MIN_PRAXIS_BET = 50
  SEND_MESSAGE_FEE = 20000000
  BASE_HP = 40
  PAID_GAMES_STRATEGIES = %i[katana annihilation random]
  FREE_GAMES_STRATEGIES = %i[random]

  WEAPONS_CACHE_TTL = 1.week.to_i
  WEAPONS_CACHE_KEY = 'weapons-cache'
  BOSSES = [
    HALLOWEEN_BOSS = :halloween
  ]

  BOT_INVOLVEMENT_RANGE = {
    free: 10..15,
    paid: 45..90
  }

  # Order is different because that's how it's used in telegram buttons
  NAME_TO_MOVE = {
    katana: 2,
    hack: 3,
    grenade: 4,
    pistol: 5,
    annihilation: 1
  }
  MOVE_TO_NAME = NAME_TO_MOVE.each_with_object({}) { |(n, m), memo| memo[m] = n }

  enum state: { created: 0, started: 1, creator_won: 2, opponent_won: 3, archived: 4 }
  enum blockchain_state: { inactive: 0, active: 1, incomplete: 2, complete: 3 }, _prefix: :blockchain
  enum bet_currency: { ton: 0, praxis: 1 }, _suffix: true

  enum visibility: { public: 0, private: 1 }, _suffix: true
  belongs_to :creator, class_name: 'User'
  belongs_to :opponent, optional: true, class_name: 'User'
  has_many :game_rounds, dependent: :destroy
  has_many :notifications, class_name: 'RockPaperScissorsNotification'

  scope :free, -> { where(bet_currency: nil) }
  scope :with_bet, -> { where.not(bet_currency: nil) }
  scope :with_ton_bet, -> { ton_bet_currency }
  scope :with_praxis_bet, -> { praxis_bet_currency }
  scope :finished, -> { where(state: %i[creator_won opponent_won]) }
  scope :not_finished, -> { where(state: %i[created started])}
  scope :with_latest_round_before, ->(date) { joins(:game_rounds).group(:id).having("MAX(game_rounds.created_at) < ?", date) }
  scope :without_rounds, -> { left_joins(:game_rounds).where(game_rounds: { id: nil } ) }

  after_create do
    # state_machine initial  callbacks don't work
    creator.lock_game_creation!

    creator.wallet&.reserve(bet) if ton_bet_currency?
    creator.praxis_wallet.reserve(bet) if praxis_bet_currency?
  end

  before_destroy do
    creator.wallet.unreserve(bet) if ton_bet_currency?
    creator.praxis_wallet.unreserve(bet) if praxis_bet_currency?

    RockPaperScissorsGames::RemoveNotifications.call(game: self, include_permanent: true)
  end

  aasm column: :state, enum: true do
    state :created, initial: true
    state :started, before_enter: -> { opponent&.lock_game_creation! }
    state :creator_won
    state :opponent_won
    state :archived

    event :start, after: :deploy, after_commit: %i[update_notifications update_free_games_count] do
      transitions from: %i[created], to: :started, after: %i[reserve_balances_after_start cache_weapons]
    end

    event :creator_win,
      after: %i[update_experience increase_experience update_last_match_at unlock_game_creation increment_completed_games],
      after_commit: [:create_user_transaction, :send_moves, :distribute_winnings, :update_tournament_statistics, :update_notifications, :decrease_durability, -> { opponent && check_player_games_balances(opponent) }] do
        transitions from: :started, to: :creator_won
      end

    event :opponent_win,
      after: %i[update_experience increase_experience update_last_match_at unlock_game_creation increment_completed_games],
      after_commit: [:create_user_transaction, :send_moves, :distribute_winnings, :update_halloween_statistic, :update_tournament_statistics, :update_notifications, :decrease_durability, -> { check_player_games_balances(creator) }] do
        transitions from: :started, to: :opponent_won
      end

    event :archive, after: %i[unreserve_balances unlock_game_creation update_notifications] do
      transitions from: %i[created started], to: :archived
    end
  end

  def can_pay?(user)
    if ton_bet_currency?
      user.wallet.reload.max_bet >= bet
    elsif praxis_bet_currency?
      user.praxis_wallet.balance >= bet
    else
      true
    end
  end

  def make_move!(from:, move:)
    validate_move(from)

    if bot
      bot_move = bot_strategy_class.new(
        game: self,
        rounds_count: game_rounds.count,
        total_damage: calculate_total_damage
      ).pick_move
      game_round_attrs = creator.bot? ? { 'opponent' => move, 'creator' => bot_move } : { 'opponent' => bot_move, 'creator' => move }
      game_round = game_rounds.build(game_round_attrs)
      result = update_round_with_winner(game_round)
      calculate_game
      result
    else
      game_round = game_rounds.order(:id).last
      key = from == creator ? 'creator' : 'opponent'

      if game_round.nil? || game_round.both_moved
        game_rounds.create!({ key => move })
      elsif game_round.public_send(key).blank?
        game_round.public_send("#{key}=", move)
        result = update_round_with_winner(game_round)

        calculate_game
        result
      else
        game_round
      end
    end
  end

  def free?
    bet_currency.blank?
  end

  def parse_bet(num)
    self.bet = [0, to_nano(num.to_f)].max
    bet
  end

  def parse_praxis_bet(num)
    self.bet = [0, num.to_i].max
    bet
  end

  def pretty_bet
    if ton_bet_currency?
      from_nano(bet)
    elsif praxis_bet_currency?
      bet.to_i
    else
      bet
    end
  end

  def force_close!
    last_round = game_rounds.last

    if ton_bet_currency?
      archive!
    elsif last_round.opponent.blank? && last_round.creator.blank?
      archive!
    elsif last_round.opponent.blank? || creator.bot?
      creator_win!
    elsif last_round.creator.blank? || opponent.bot?
      opponent_win!
    else
      archive!
    end

    if free?
      Users::GameLeavePenalty.new(creator).create if last_round.creator.blank?
      Users::GameLeavePenalty.new(opponent).create if last_round.opponent.blank?
    end

    send_game_close_notification

    true
  end

  def increment_completed_games
    Users::GameLeavePenalty.new(creator).increment_completed_games
    Users::GameLeavePenalty.new(opponent).increment_completed_games if opponent
  end

  def send_creation_notifications
    RockPaperScissorsGames::SendNotificationsWorker.perform_async(id) if !free? && public_visibility?
  end

  def total_damage
    @total_damage ||= calculate_total_damage
  end

  def need_game_image?
    boss.present? || !free?
  end

  def cache_weapons
    update_current_weapons
    weapons = { creator_id => creator.items_users.equipped.pluck(:id) }
    weapons = weapons.merge(opponent_id => opponent.items_users.equipped.pluck(:id)) if opponent_id

    self.class.redis.setex("#{WEAPONS_CACHE_KEY}-#{id}", WEAPONS_CACHE_TTL, weapons.to_json)
  end

  def cached_weapons
    @cached_weapons ||= begin
      cache = self.class.redis.get("#{WEAPONS_CACHE_KEY}-#{id}")
      return if cache.blank?

      JSON.parse(cache).each_with_object({}) do |(user_id, isers_users), memo|
        memo[user_id.to_i] = Items::Weapon.joins(:items_users).where(items_users: { id: isers_users }).index_by(&:position)
      end
    end
  end

  def cached_items_users
    @cached_items_users ||= begin
      cache = self.class.redis.get("#{WEAPONS_CACHE_KEY}-#{id}")
      return if cache.blank?

      JSON.parse(cache).each_with_object({}) do |(user_id, isers_users), memo|
        memo[user_id.to_i] = ItemsUser.where(id: isers_users).to_a
      end
    end
  end

  def has_effect?(effect_name, user)
    current_effects.dig(user&.id, effect_name).present?
  end

  def available_moves(user)
    return %i[hack annihilation].map { NAME_TO_MOVE[_1] } if has_effect?('onearmed_bandit', user)
    return %i[katana grenade pistol].map { NAME_TO_MOVE[_1] } if has_effect?('blinding_light', user)

    MOVE_TO_NAME.keys
  end

  def opponent_health
    @opponent_health ||= opponent&.health || User::BASE_HP
  end

  def creator_health
    @creator_health ||= creator.health
  end

  private

  def update_current_weapons
    weapons = { "creator" => creator.items_users.equipped.map(&:item_id) }
    weapons = weapons.merge("opponent" => opponent.items_users.equipped.map(&:item_id)) if opponent_id

    update(current_weapons: weapons)
  end

  def update_round_with_winner(game_round)
    result = GameRounds::NeoCalculateWinner.call(game_round: game_round, total_damage: calculate_total_damage, weapons: cached_weapons)
    game_round.update!(winner: result.winner, creator_damage: result.creator_total_damage.to_i, opponent_damage: result.opponent_total_damage.to_i)
    result
  end

  def reserve_balances_after_start
    if ton_bet_currency?
      opponent&.wallet&.reserve(bet)
    elsif praxis_bet_currency?
      opponent.praxis_wallet.reserve(bet)
    end
  end

  def calculate_total_damage
    game_rounds.reload.each_with_object({ "opponent" => 0, "creator" => 0 }) do |round, memo|
      memo['creator'] += round.creator_damage
      memo['opponent'] += round.opponent_damage
    end
  end

  def send_game_close_notification
    RockPaperScissorsGames::SendGameCloseNotificationsWorker.perform_async(id)
  end

  def deploy
    RockPaperScissorsGames::DeployGame.call(game: self) if ton_bet_currency?
  end

  def calculate_game
    return if creator_won? || opponent_won? || archived?

    if total_damage["opponent"] >= creator_health
      opponent_win!
    elsif total_damage["creator"] >= opponent_health
      creator_win!
    else
      false
    end
  end

  def send_moves
    RockPaperScissorsGames::SendMovesWorker.perform_async(id) if ton_bet_currency?
  end

  def update_experience
    update(creator_experience: calculated_creator_experience, opponent_experience: calculated_opponent_experience)
  end

  def increase_experience
    creator.add_experience!(creator_experience, game: self)
    opponent&.add_experience!(opponent_experience, game: self)
  end

  def check_player_games_balances(player)
    return unless ton_bet_currency?

    player.created_rock_paper_scissors_games.created.each do |game|
      RockPaperScissorsGames::ValidateCreatorBalance.call(game: game)
    end
  end

  def update_last_match_at
    creator.touch(:last_match_at)
    opponent&.touch(:last_match_at)
  end

  def unlock_game_creation
    creator.unlock_game_creation!
    opponent&.unlock_game_creation!
  end

  def calculated_creator_experience
    calculated_experience(creator, creator_won?)
  end

  def calculated_opponent_experience
    return if opponent.blank?

    calculated_experience(opponent, opponent_won?)
  end

  def calculated_experience(user, user_won)
    CalculateExperience.call(game: self, won: user_won, user: user, boss_fight: boss.present?)
  end

  def update_halloween_statistic
    return if boss.blank?

    statistic = UserHalloweenStatistic.find_or_create_by(user: creator)
    damage = game_rounds.sum { |round| round.winner == "creator" ? round.winner_damage.to_i : round.loser_damage.to_i }
    statistic.increment!(:total_damage, damage)
  end

  def validate_move(from)
    raise ArgumentError, "Move creator is wrong" if creator != from && opponent != from
  end

  def update_notifications
    RockPaperScissorsGames::UpdateNotificationsWorker.perform_async(id) if notifications.any?
  end

  def unreserve_balances
    if ton_bet_currency?
      creator.wallet&.unreserve(bet)
      opponent&.wallet&.unreserve(bet)
    elsif praxis_bet_currency?
      creator.praxis_wallet.unreserve(bet)
      opponent&.praxis_wallet&.unreserve(bet)
    end
  end

  def update_free_games_count
    RockPaperScissorsGames::FreeGamesCounter.increment if free? && boss.blank?
  end

  def bot_strategy_class
    @bot_strategy_class ||= RockPaperScissorsGames.const_get("#{bot_strategy.classify}Strategy")
  end

  def create_user_transaction
    return unless ton_bet_currency?

    [creator, opponent].each do |user|
      next unless user

      UserTransaction.create!(
        user_session: user.sessions.open.first,
        user: user,
        total: bet,
        commission: bet * 0.1,
        transaction_type: "rock_paper_scissors_game"
      )
    end
  end

  def distribute_winnings
    if praxis_bet_currency?
      distribute_praxis_winnings
    elsif ton_bet_currency?
      distribute_ton_referral_reward
    end
  end

  def distribute_praxis_winnings
    RockPaperScissorsGames::PraxisWinningsDistribution.call(game: self)
  end

  def distribute_ton_referral_reward
    RockPaperScissorsGames::TonReferralRewardDistribution.call(game: self)
  end

  def update_tournament_statistics
    FreeTournaments::ContributePrizePool.call(game: self)
    FreeTournaments::ContributionWorker.perform_in(5, creator.id, id)
    FreeTournaments::ContributionWorker.perform_in(5, opponent.id, id) if opponent.present?
  end

  def decrease_durability
    RockPaperScissorsGames::DecreaseWeaponsDurabilityWorker.perform_in(3, id)
  end

  def current_effects
    @current_effects ||= begin
      effects = self.class.redis.get("#{GameRounds::NeoCalculateWinner::EFFECTS_KEY}-#{id}")
      return {} if effects.blank?

      JSON.parse(effects).transform_keys(&:to_i)
    end
  end
end
