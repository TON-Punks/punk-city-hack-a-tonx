class TelegramImage
  class << self
    def path(file_path)
      Rails.root.join("telegram_assets/images/#{I18n.locale}/#{file_path}")
    end
  end
end
