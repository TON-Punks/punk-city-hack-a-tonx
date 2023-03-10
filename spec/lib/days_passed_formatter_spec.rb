# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DaysPassedFormatter do
  {
    ru: {
      1 => "1 день",
      2 => "2 дня",
      5 => "5 дней",
      24 => "24 дня",
      133 => "133 дня"
    },
    en: {
      1 => "1 day",
      2 => "2 days",
      39 => "39 days"
    }
  }.each do |locale, test_cases|
    test_cases.each do |days_count, expected_result|
      specify do
        I18n.with_locale(locale) do
          expect(described_class.call(days_count)).to eq(expected_result)
        end
      end
    end
  end
end
