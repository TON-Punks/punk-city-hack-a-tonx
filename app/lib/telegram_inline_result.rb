class TelegramInlineResult < SymbolizeStruct
  attribute :type, Types::String
  attribute :id, Types::Coercible::String
  attribute? :photo_url, Types::String
  attribute :thumb_url, Types::String
  attribute? :photo_height, Types::Integer
  attribute? :photo_width, Types::Integer
  attribute :title, Types::String
  attribute? :description, Types::String
  attribute? :parse_mode, Types::String
  attribute? :caption, Types::String
  attribute? :reply_markup do
    attribute :inline_keyboard, Types::Array
  end
  attribute? :input_message_content do
    attribute :message_text, Types::String
    attribute :parse_mode, Types::String
  end
end
