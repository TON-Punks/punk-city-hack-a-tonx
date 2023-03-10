class UserTonTransactionFetcher
  extend TonHelper

  ALLOWED_COMISSION_DIFFERENCE = 0.1

  class << self
    def call(from_address:, to_address:, ton_amount:, excluded_hashes: [])
      transactions = toncenter_client.account_transactions(address: from_address)

      purchase_transaction = transactions.detect do |transaction|
        1.hour.ago.to_i < transaction["utime"].to_i &&
          transaction["out_msgs"].first.present? &&
          transaction["out_msgs"].first["destination"] == to_address &&
          transaction["out_msgs"].first["value"].to_i > to_nano(ton_amount - ALLOWED_COMISSION_DIFFERENCE) &&
          excluded_hashes.exclude?(transaction.dig("transaction_id", "hash"))
      end

      purchase_transaction.present? ? purchase_transaction.dig("transaction_id", "hash") : nil
    end

    private

    def toncenter_client
      @toncenter_client ||= ToncenterClient.new
    end
  end
end
