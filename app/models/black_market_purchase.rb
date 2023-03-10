# == Schema Information
#
# Table name: black_market_purchases
#
#  id                      :bigint           not null, primary key
#  data                    :json             not null
#  payment_amount          :decimal(16, 10)  default(0.0), not null
#  payment_method          :integer          default("praxis"), not null
#  seller_comission_amount :decimal(16, 10)  default(0.0), not null
#  state                   :integer          default("initiated"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  black_market_product_id :bigint           not null
#  praxis_transaction_id   :bigint
#  seller_user_id          :bigint
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_black_market_purchases_on_black_market_product_id  (black_market_product_id)
#  index_black_market_purchases_on_praxis_transaction_id    (praxis_transaction_id)
#  index_black_market_purchases_on_seller_user_id           (seller_user_id)
#  index_black_market_purchases_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (black_market_product_id => black_market_products.id)
#  fk_rails_...  (praxis_transaction_id => praxis_transactions.id)
#  fk_rails_...  (user_id => users.id)
#
class BlackMarketPurchase < ApplicationRecord
  belongs_to :user
  belongs_to :seller_user, optional: true, class_name: 'User'

  belongs_to :black_market_product
  belongs_to :praxis_transaction, optional: true

  has_one :lootbox

  enum state: { initiated: 0, paid: 1, seller_paid: 2, completed: 3, failed: 4 }
  enum payment_method: { praxis: 0, ton: 1 }, _suffix: true
end
