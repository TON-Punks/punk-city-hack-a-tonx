class DaysPassedFormatter
  MAPPING = { ru: :days_passed_ru, en: :days_passed_en }.freeze

  class << self
    def call(days)
      send(MAPPING.fetch(I18n.locale.to_sym), days)
    end

    private

    def days_passed_ru(days)
      return translated_days(:many, days) if days % 100 / 10 == 1

      case days % 10
      when 1 then translated_days(:one, days)
      when 2 then translated_days(:few, days)
      when 3 then translated_days(:other, days)
      when 4 then translated_days(:other, days)
      else translated_days(:many, days)
      end
    end

    def days_passed_en(days)
      days == 1 ? translated_days(:one, days) : translated_days(:many, days)
    end

    def translated_days(modifier, days)
      I18n.t(modifier, count: days, scope: "datetime.distance_in_words.x_days")
    end
  end
end
