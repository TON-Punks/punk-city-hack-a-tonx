class TelegramRequest::Chat < SymbolizeStruct
  attribute :id, Types::Coercible::Integer
  attribute? :first_name, Types::String
  attribute? :last_name, Types::String.optional
  attribute? :username, Types::String.optional
  attribute? :title, Types::String.optional
  attribute :type, Types::String

  def name
    self.username || "#{self.first_name} #{self.last_name}"
  end

  def channel?
    self.type == 'channel'
  end

  def group?
    %w[group supergroup].include?(self.type)
  end
end
