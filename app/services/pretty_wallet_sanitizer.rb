class PrettyWalletSanitizer
  class << self
    def call(wallet)
      wallet.to_s.gsub("_", "\\_")
    end
  end
end
