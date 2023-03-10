# == Schema Information
#
# Table name: user_transactions
#
#  id               :bigint           not null, primary key
#  commission       :bigint           not null
#  total            :bigint           not null
#  transaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#  user_session_id  :bigint
#
# Indexes
#
#  index_user_transactions_on_user_id          (user_id)
#  index_user_transactions_on_user_session_id  (user_session_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (user_session_id => user_sessions.id)
#
class UserTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :user_session, optional: true
end
