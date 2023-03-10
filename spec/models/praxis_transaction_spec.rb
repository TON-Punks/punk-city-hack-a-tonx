require 'rails_helper'

RSpec.describe PraxisTransaction, type: :model do
  describe '.balance' do
    let(:user) { create(:user) }

    before do
      create(:praxis_transaction, user: user, operation_type: :fast_exchange, quantity: 130)
      create(:praxis_transaction, user: user, operation_type: :premium_exchange, quantity: 200)
      create(:praxis_transaction, user: user, operation_type: :product_purchase, quantity: 260)
      create(:praxis_transaction, operation_type: :regular_exchange, quantity: 900)
    end

    specify do
      expect(user.praxis_transactions.balance).to eq(70)
    end
  end
end
