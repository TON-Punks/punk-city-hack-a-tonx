class TelegramButton < SymbolizeStruct
  attribute :text, Types::Coercible::String
  attribute? :data, Types::String
  attribute? :game_short_name, Types::String
  attribute? :callback_data, Types::String
  attribute? :url, Types::String
  attribute? :switch_inline_query, Types::String

  attribute? :web_app do
    attribute :url, Types::String
  end
end
