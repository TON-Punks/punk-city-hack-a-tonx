# == Schema Information
#
# Table name: praxis_transactions
#
#  id             :bigint           not null, primary key
#  operation_type :integer          not null
#  quantity       :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_praxis_transactions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PraxisTransaction < ApplicationRecord
  belongs_to :user

  OPERATION_TYPES = [
    FAST_EXCHANGE = :fast_exchange,
    REGULAR_EXCHANGE = :regular_exchange,
    PREMIUM_EXCHANGE = :premium_exchange,
    TON_EXCHANGE = :ton_exchange,
    PRODUCT_PURCHASE = :product_purchase,
    PRODUCT_SOLD = :product_sold,
    CONNECTED_PUNK_BONUS = :connected_punk_bonus,
    P2P_RECEIVED = :p2p_received,
    P2P_SENT = :p2p_sent,
    TONARCHY_SPONSORSHIP = :tonarchy_sponsorship,
    RESERVED = :reserved,
    UNRESERVED = :unreserved,
    GAME_WON = :game_won,
    GAME_LOST = :game_lost,
    TOURNAMENT_WON = :tournament_won,
    REFERRAL_BONUS = :referral_bonus,
    WEAPON_REPAIRED = :weapon_repaired,
    NEUROBOX_LITE = :neurobox_lite
  ].freeze

  OPERATIONS_TO_NOTIFY = [
    REGULAR_EXCHANGE,
    PREMIUM_EXCHANGE,
    TON_EXCHANGE,
    PRODUCT_SOLD,
    GAME_WON,
    GAME_LOST,
    TOURNAMENT_WON,
    NEUROBOX_LITE
  ].freeze

  PURCHASE_OPERATIONS = [
    FAST_EXCHANGE,
    REGULAR_EXCHANGE,
    PREMIUM_EXCHANGE,
    TON_EXCHANGE,
    PRODUCT_SOLD,
    CONNECTED_PUNK_BONUS,
    P2P_RECEIVED,
    UNRESERVED,
    GAME_WON,
    TOURNAMENT_WON,
    REFERRAL_BONUS,
    NEUROBOX_LITE
  ].freeze

  SPEND_OPERATIONS = [
    PRODUCT_PURCHASE,
    P2P_SENT,
    TONARCHY_SPONSORSHIP,
    RESERVED,
    GAME_LOST,
    WEAPON_REPAIRED
  ].freeze

  enum operation_type: {
    FAST_EXCHANGE => 0,
    REGULAR_EXCHANGE => 1,
    PREMIUM_EXCHANGE => 2,
    PRODUCT_PURCHASE => 3,
    TON_EXCHANGE => 4,
    PRODUCT_SOLD => 5,
    CONNECTED_PUNK_BONUS => 6,
    P2P_RECEIVED => 7,
    P2P_SENT => 8,
    TONARCHY_SPONSORSHIP => 9,
    RESERVED => 10,
    UNRESERVED => 11,
    GAME_WON => 12,
    GAME_LOST => 13,
    TOURNAMENT_WON => 14,
    REFERRAL_BONUS => 15,
    WEAPON_REPAIRED => 16,
    NEUROBOX_LITE => 17
  }

  validates :user, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  after_create do |praxis_transaction|
    Praxis::BalanceChangedWorker.perform_in(3, praxis_transaction.id)
  end

  scope :purchased, -> { where(operation_type: PURCHASE_OPERATIONS) }
  scope :spent, -> { where(operation_type: SPEND_OPERATIONS) }

  scope :purchased_sum, -> { purchased.sum(:quantity) }
  scope :spent_sum, -> { spent.sum(:quantity) }

  scope :for_today, -> { where(created_at: Time.now.utc.beginning_of_day..) }

  class << self
    def balance
      purchased_sum - spent_sum
    end

    def reserved_balance
      reserved.sum(:quantity) - unreserved.sum(:quantity)
    end
  end
end
