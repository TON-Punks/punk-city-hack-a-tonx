# == Schema Information
#
# Table name: withdraw_requests
#
#  id         :bigint           not null, primary key
#  address    :string
#  amount     :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wallet_id  :bigint           not null
#
# Indexes
#
#  index_withdraw_requests_on_wallet_id  (wallet_id)
#
# Foreign Keys
#
#  fk_rails_...  (wallet_id => wallets.id)
#
class WithdrawRequest < ApplicationRecord
  include TonHelper

  belongs_to :wallet
  has_one :user, through: :wallet

  def pretty_amount
    from_nano(amount)
  end

  def parse_amount!(num)
    update(amount: to_nano(num.to_f))
    amount
  end
end
