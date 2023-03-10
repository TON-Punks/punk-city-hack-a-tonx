class Praxis::RegularExchangeTime < SymbolizeStruct
  attribute :interval, Types::Integer
  attribute :until_reset, Types::Float
  attribute :humanized_interval, Types::String
  attribute :humanized_until_reset, Types::String
  attribute :humanized_ongoing_interval, Types::String
end
