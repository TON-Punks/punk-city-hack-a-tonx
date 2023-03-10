# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramImage do
  let(:file_path) { "punk_city.png" }

  I18n.available_locales.each do |locale|
    specify "path for #{locale}" do
      I18n.locale = locale

      expect(described_class.path(file_path).to_s).to include("telegram_assets/images/#{locale}/#{file_path}")
    end
  end
end
