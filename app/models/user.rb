# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  chat_rep                      :bigint           default(0), not null
#  experience                    :bigint           default(0), not null
#  first_name                    :string
#  free_lootboxes_rewarded_level :integer          default(0), not null
#  last_match_at                 :datetime
#  last_name                     :string
#  locale                        :string
#  next_step                     :string
#  notifications_disabled_at     :datetime
#  onboarded                     :boolean          default(FALSE), not null
#  prestige_expirience           :integer          default(0), not null
#  prestige_level                :integer          default(0), not null
#  provided_wallet               :string
#  unsubscribed_at               :datetime
#  username                      :string
#  utm_source                    :string
#  viewed_tutorial_at            :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  chat_id                       :string           not null
#
# Indexes
#
#  index_users_on_chat_id  (chat_id) UNIQUE
#
class User < ApplicationRecord
  include AfterCommitEverywhere
  extend RedisHelper

  GAME_LOCKING_KEY = "user-locked-creation"
  USER_AUTH_TOKEN_KEY = "user-auth-token"
  AUTH_TOKEN_KEY = "auth-token"
  AUTH_TOKEN_TTL = 20.minutes.to_i
  BASE_HP = 40

  has_many :referrals
  has_many :referred_users, through: :referrals, source: :referred
  has_one :referred_referral, class_name: 'Referral', inverse_of: :referred, foreign_key: :referred_id
  has_one :referred_by, through: :referred_referral, source: :user
  has_many :referral_rewards

  has_many :punk_connections
  has_one :connected_punk_connection, -> { connected }, class_name: 'PunkConnection'
  has_one :punk, through: :connected_punk_connection

  has_one :rock_paper_scissors_statistic
  has_one :halloween_statistic, class_name: 'UserHalloweenStatistic'
  has_many :created_rock_paper_scissors_games,
    foreign_key: :creator_id,
    inverse_of: :creator,
    class_name: 'RockPaperScissorsGame',
    dependent: :destroy
  has_many :participated_rock_paper_scissors_games,
    foreign_key: :opponent_id,
    inverse_of: :creator,
    class_name: 'RockPaperScissorsGame',
    dependent: :destroy

  has_one :platformer_statistic
  has_one :zeya_statistic
  has_many :platformer_games
  has_many :zeya_games

  has_one :wallet, dependent: :nullify

  has_many :praxis_transactions
  has_many :black_market_purchases
  has_many :lootbox_black_market_purchases, class_name: 'BlackMarketPurchase'
  has_many :lootboxes, through: :lootbox_black_market_purchases

  has_many :sessions, class_name: 'UserSession'

  has_many :battle_passes
  has_one :halloween_pass, -> { halloween }, class_name: 'BattlePass'
  has_many :tournament_tickets

  has_many :ab_testing_experiments
  has_many :segments_users
  has_many :segments, through: :segments_users
  has_many :items_users
  has_many :items, through: :items_users
  has_many :weapons, -> { weapons }, through: :items_users, source: :item

  has_many :missions
  has_many :neurobox_level_missions, class_name: Missions::NeuroboxLevelMission.name

  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }, allow_nil: true

  after_create :recalculate_rock_paper_scissors_statistic!, :recalculate_platformer_statistic!, :recalculate_zeya_statistic!
  after_create do
    create_default_weapons
    Users::UpdateProfileWorker.perform_async(id)
  end

  # [DEPRECATED] These columns should be removed some time after stabilization
  self.ignored_columns = [:expirience, :total_experience, :level]

  scope :by_platformer_score, -> { joins(:platformer_statistic).order('top_score' => :desc) }
  scope :by_zeya_score, -> { joins(:zeya_statistic).order('top_score' => :desc) }
  scope :by_halloween_total_damage, -> { joins(:halloween_statistic).order('total_damage' => :desc) }
  scope :by_winrate, -> { joins(:rock_paper_scissors_statistic).order('winrate' => :desc) }
  scope :by_ton_won, -> { joins(:rock_paper_scissors_statistic).order('ton_won' => :desc) }
  scope :by_level, lambda {
    left_joins(:punk)
      .order(
        Arel.sql('
          CASE
          WHEN punks.id IS NOT NULL THEN punks.prestige_level ELSE users.prestige_level
         END DESC'
       )
     )
     .order(
       Arel.sql('
         CASE
           WHEN punks.id IS NOT NULL THEN punks.prestige_expirience ELSE users.prestige_expirience
          END DESC'
        )
      )
  }
  scope :notifiable, -> { where(unsubscribed_at: nil, notifications_disabled_at: nil) }

  def self.find_by_auth_token!(token)
    find(redis.get("#{AUTH_TOKEN_KEY}-#{token}"))
  end

  def update_current_session!
    Users::UpdateCurrentSession.call(user: self)
  end

  def identification
    if punk
      "TON PUNK ##{punk.number}"
    elsif username
      "#{username}"
    elsif first_name || last_name
      "#{first_name} #{last_name}".strip
    else
      "ANON ##{chat_id}"
    end
  end

  def with_locale
    I18n.with_locale(locale.presence || I18n.default_locale) do
      yield
    end
  end

  def pretty_provided_wallet
    return '' if provided_wallet.blank?

    "#{provided_wallet.first(5)}.....#{provided_wallet.last(5)}"
  end

  def effective_prestige_level
    actor.prestige_level
  end

  def effective_prestige_expirience
    actor.prestige_expirience
  end

  def effective_experience
    actor.experience
  end

  def equipped_weapons
    weapons.joins(:items_users).where("items_users.data->>'equipped' = 'true'").distinct
  end

  def experience_balance_valid?
    (experience.zero? || experience.positive?) &&
      (punk.present? ? (punk.experience.zero? || punk.experience.positive?) : true)
  end

  def praxis_wallet
    @praxis_wallet ||= UserPraxisWallet.new(self)
  end

  def praxis_balance_valid?
    praxis_wallet.balance_valid?
  end

  def praxis_balance
    praxis_wallet.balance
  end

  def rock_paper_scissors_games_wins
    @rock_paper_scissors_games_wins ||= begin
      created_wins = created_rock_paper_scissors_games.where(state: :creator_won).count
      other_wins = participated_rock_paper_scissors_games.where(state: :opponent_won).count
      created_wins + other_wins
    end
  end

  def rock_paper_scissors_games_total
    @rock_paper_scissors_games_total ||= created_rock_paper_scissors_games.finished.count + \
      participated_rock_paper_scissors_games.finished.count
  end

  def rock_paper_scissors_games_losses
    rock_paper_scissors_games_total - rock_paper_scissors_games_wins
  end

  def add_experience!(number, include_reffered_by: true, game: nil)
    ApplicationRecord.transaction do
      new_prestige_expirience = effective_prestige_expirience + number

      if new_prestige_expirience < new_prestige_level_threshold(actor.prestige_level)
        actor.increment!(:prestige_expirience, number)
      else
        actor.update({ prestige_expirience: new_prestige_expirience - new_prestige_level_threshold(actor.prestige_level), prestige_level: actor.prestige_level + 1 })
        Missions::NeuroboxLevel::Contributor.call(user: self)
      end

      actor.increment!(:experience, number)

      if include_reffered_by && referred_by
        referred_by.add_experience!(2, include_reffered_by: false)
        ReferralReward.for(self, game).update!(experience: 2) if game
      end
    end
  end

  def remove_experience!(amount)
    actor.decrement!(:experience, amount)
  end

  def new_prestige_level_threshold(lvl)
    LevelsThreshold::LIST[lvl] || LevelsThreshold::LIST.last
  end

  def can_start_new_game?
    !self.class.redis.get("#{GAME_LOCKING_KEY}-#{id}")
  end

  def leave_penalty?
    Users::GameLeavePenalty.new(self).exists?
  end

  def lock_game_creation!
    self.class.redis.set("#{GAME_LOCKING_KEY}-#{id}", true)
  end

  def unlock_game_creation!
    self.class.redis.del("#{GAME_LOCKING_KEY}-#{id}")
  end

  def recalculate_rock_paper_scissors_statistic!
    statistic = rock_paper_scissors_statistic || RockPaperScissorsStatistic.new(user: self)
    RockPaperScissorsStatistics::Recalculate.call(statistic:  statistic)
  end

  def recalculate_platformer_statistic!
    statistic = platformer_statistic || PlatformerStatistic.new(user: self)
    PlatformerStatistics::Recalculate.call(statistic:  statistic)
  end

  def recalculate_zeya_statistic!
    statistic = zeya_statistic || ZeyaStatistic.new(user: self)
    ZeyaStatistics::Recalculate.call(statistic:  statistic)
  end

  def actor
    punk.presence || self
  end

  def bot?
    @bot ||= TelegramConfig.bot_ids.include?(id)
  end

  def profile_url
    timestamp = [rock_paper_scissors_statistic.updated_at.to_i, updated_at.to_i].max
    AwsConfig.profile_url(id, cache: timestamp)
  end

  def weapons_image_url
    timestamp = [items_users.maximum(:updated_at).to_i, updated_at.to_i].max
    AwsConfig.weapons_url(id, cache: timestamp)
  end

  def auth_token
    key = "#{USER_AUTH_TOKEN_KEY}-#{id}"
    token = self.class.redis.get(key)
    return token if token

    token = SecureRandom.urlsafe_base64
    self.class.redis.setex(key, AUTH_TOKEN_TTL, token)
    self.class.redis.setex("#{AUTH_TOKEN_KEY}-#{token}", AUTH_TOKEN_TTL, id)
    token
  end

  def experiment_participant?(experiment_type)
    ab_testing_experiments.where(type: experiment_type.name).first_or_create!.participates?
  end

  def segment_for(segment_type)
    segments_users.joins(:segment).where(segments: { type: segment_type.name }).first&.segment
  end

  def health
    @health ||= BASE_HP + equipped_weapons.sum { _1.perks.to_h['health'].to_i }
  end

  def create_default_weapons
    self.items = Items::Weapon.default

    self.class.transaction do
      items_users.each(&:equip!)
      after_commit do
        Users::UpdateWeaponsImageWorker.perform_async(id)
      end
    end
  end
end
