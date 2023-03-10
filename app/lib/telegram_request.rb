class TelegramRequest < SymbolizeStruct
  attribute? :edited_message do
    attribute? :text, Types::String
    attribute :from, TelegramRequest::From
    attribute :chat,  TelegramRequest::Chat
  end

  attribute? :callback_query do
    attribute :id, Types::Coercible::Integer
    attribute? :data, Types::String
    attribute :from, TelegramRequest::From
    attribute? :message do
      attribute? :text, Types::String
      attribute :message_id, Types::Coercible::Integer
      attribute? :from, TelegramRequest::From
      attribute :chat,  TelegramRequest::Chat

      attribute? :game do
        attribute :title, Types::String
      end
    end

    attribute? :game_short_name, Types::String
  end

  attribute? :message do
    attribute? :message_id, Types::Coercible::Integer
    attribute? :text, Types::String
    attribute? :from, TelegramRequest::From
    attribute :chat,  TelegramRequest::Chat
    attribute? :forward_from_chat, TelegramRequest::Chat

    alias_method :forwarded, :forward_from_chat

    def command
      @command ||= self.text.to_s.downcase.tr('/', '').split(' ').first.to_s.inquiry
    end

    def command_options
      self.text.to_s.tr('/', '').split(' ')[1..-1].presence
    end
  end

  attribute? :my_chat_member do
    attribute :from, TelegramRequest::From
    attribute :chat,  TelegramRequest::Chat
    attribute :new_chat_member do
      attribute :user, TelegramRequest::From
      attribute? :status, Types::Coercible::String.optional
    end
  end

  attribute? :chat_join_request do
  end

  attribute? :inline_query do
    attribute :id, Types::Coercible::Integer
    attribute :from, TelegramRequest::From
    attribute :query, Types::String
  end

  attribute? :chosen_inline_result do
    attribute :from, TelegramRequest::From
    attribute :result_id, Types::Coercible::Integer
    attribute :inline_message_id, Types::String
  end

  def root
    self.message || self.my_chat_member || self.callback_query&.message
  end

  def chat_id
    inline_query&.from&.id || chosen_inline_result&.from&.id || root&.chat&.id || self&.callback_query&.from&.id
  end

  def new_status
    self.my_chat_member&.new_chat_member&.status.to_s.inquiry
  end

  def status_update?
    new_status.present?
  end

  def from_group?
    message&.chat&.group?
  end
end
