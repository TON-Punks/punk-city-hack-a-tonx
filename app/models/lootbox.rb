# == Schema Information
#
# Table name: lootboxes
#
#  id                       :bigint           not null, primary key
#  address                  :text
#  prepaid                  :boolean          default(FALSE), not null
#  result                   :jsonb
#  series                   :text             not null
#  state                    :integer          default("created"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  black_market_purchase_id :bigint
#
# Indexes
#
#  index_lootboxes_on_black_market_purchase_id  (black_market_purchase_id)
#
class Lootbox < ApplicationRecord
  ALL_SERIES = %w[initial lite].freeze

  belongs_to :black_market_purchase, optional: true
  has_one :user, through: :black_market_purchase

  enum state: { created: 0, in_progress: 1, done: 2 }
  enum series: ALL_SERIES.zip(ALL_SERIES).to_h, _suffix: true

  scope :prepaid, -> { where(prepaid: true) }
  scope :not_prepaid, -> { where(prepaid: false) }
end
