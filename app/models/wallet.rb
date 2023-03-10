# == Schema Information
#
# Table name: wallets
#
#  id                    :bigint           not null, primary key
#  address               :string
#  balance               :bigint
#  base64_address        :string
#  base64_address_bounce :string
#  state                 :integer          default("inactive"), not null
#  virtual_balance       :bigint           default(0), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :bigint
#
# Indexes
#
#  index_wallets_on_base64_address_bounce  (base64_address_bounce)
#  index_wallets_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Wallet < ApplicationRecord
  include TonHelper

  belongs_to :user
  has_one :credential, class_name: 'WalletCredential'

  enum state: { inactive: 0, active: 1 }

  def pretty_balance
    from_nano(balance)
  end

  def pretty_virtual_balance(round: false)
    from_nano(virtual_balance, round)
  end

  def pretty_address
    if active? && balance.to_i > 0
      base64_address_bounce
    else
      base64_address
    end
  end

  def sanitized_pretty_address
    PrettyWalletSanitizer.call(pretty_address)
  end

  def max_bet
    virtual_balance.to_i - RockPaperScissorsGame::SEND_MESSAGE_FEE
  end

  def pretty_max_bet
    from_nano(max_bet)
  end

  def reserve(ton)
    self.decrement(:virtual_balance, ton)
  end

  def unreserve(ton)
    self.increment(:virtual_balance, ton)
  end
end
