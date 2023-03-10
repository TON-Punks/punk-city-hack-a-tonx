# == Schema Information
#
# Table name: wallet_credentials
#
#  id         :bigint           not null, primary key
#  mnemonic   :text
#  public_key :text
#  secret_key :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wallet_id  :bigint           not null
#
# Indexes
#
#  index_wallet_credentials_on_wallet_id  (wallet_id)
#
# Foreign Keys
#
#  fk_rails_...  (wallet_id => wallets.id)
#
class WalletCredential < ApplicationRecord
  belongs_to :wallet
end
