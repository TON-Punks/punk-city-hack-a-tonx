class TelegramRequest::From < SymbolizeStruct
  attribute :id, Types::Coercible::Integer
  attribute? :is_bot, Types::Params::Bool
  attribute? :first_name, Types::String
  attribute? :last_name, Types::String.optional
  attribute? :username, Types::String.optional
  attribute? :language_code, Types::String
end
