class NewTransactionsMonitoringTonhub
  class << self
    def call
      transactions = FetchLastTransactions.new.call

      return if transactions.empty?

      mapping = transactions.each_with_object({}) do |transaction, acc|
        acc[transaction["account"]] = transaction["hash"]
      end

      check_wallets(mapping)
      check_lootboxes(mapping.keys)
    end

    def check_wallets(mapping)
      wallets = Wallet.where(base64_address_bounce: mapping.keys).includes(:user)
      return unless wallets.exists?

      wallets.each do |wallet|
        if wallet.inactive?
          Wallets::DeployWorker.perform_async(wallet.id)
        else
          Wallets::UpdateBalanceWorker.perform_async(wallet.id)
        end

        user = wallet.user
        Users::CheckPunkConnectionWorker.perform_in(60, user.id) if user.punk_connections.requested.exists?
      end
    end

    def check_lootboxes(mapping_keys)
      if mapping_keys.include?(ContractsConfig.contracts_address['lootboxes']) || mapping_keys.include?(ContractsConfig.contracts_address['lootboxes_lite'])
        Lootboxes::CheckResultWorker.perform_in(3)
      end
    end
  end
end
