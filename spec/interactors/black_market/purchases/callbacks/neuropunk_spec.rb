require 'rails_helper'

RSpec.describe BlackMarket::Purchases::Callbacks::Neuropunk do
  subject { described_class.call(purchase: purchase) }

  let(:punk) { create(:punk, number: punk_number) }

  let(:product) { create(:black_market_product) }
  let(:punk_number) { 111 }
  let(:purchase) do
    create(:black_market_purchase, black_market_product: product, payment_method: :ton, payment_amount: 100, data: { punk_number: punk_number })
  end
  let(:punk_url) { 'https://link.com/punk.mp4' }

  let(:payment_amount) { product_price }
  let(:notification_message) do
    I18n.t("admin.notifications.neuropunk_purchased.common",
      punk_number: punk.number,
      punk_url: punk.punk_url,
      payment_amount: purchase.payment_amount,
      payment_currency: purchase.payment_method.upcase,
      wallet: purchase.user.provided_wallet,
      transaction_info: transaction_info_message
    )
  end

  let(:transaction_info_message) do
    I18n.t("admin.notifications.neuropunk_purchased.ton",
      user_transaction: purchase.data["user_transaction_hash"],
      seller_transaction: purchase.data["seller_transaction_hash"]
    )
  end

  before do
    allow(punk).to receive(:punk_url).and_return(punk_url)
    allow(Punk).to receive(:find_by).with(number: punk_number).and_return(punk)
    allow(Telegram::Notifications::InternalAdmin).to receive(:call).with(
      admin_chat_id: described_class::NOTIFICATIONS_CHAT_ID,
      message: notification_message
    )
  end

  specify do
    expect(Telegram::Notifications::InternalAdmin).to receive(:call).with(
      admin_chat_id: described_class::NOTIFICATIONS_CHAT_ID,
      message: notification_message
    )

    subject
  end
end
