class Api::InitDataProcessor
  include Interactor

  delegate :init_data, to: :context

  def call
    context.fail!(error_message: "Invalid init data") if provided_signature.blank? || invalid_signature?

    user = User.find_by(chat_id: parsed_user_data["id"])
    context.fail!(error_message: "User not found") if user.blank?

    context.user = user
  end

  private

  def parsed_user_data
    @parsed_user_data ||= JSON.parse(parsed_data["user"])
  end

  def invalid_signature?
    provided_signature != calculated_signature
  end

  def provided_signature
    @provided_signature ||= parsed_data["hash"].to_s
  end

  def calculated_signature
    OpenSSL::HMAC.hexdigest(digest, bot_token_digest, check_string_data)
  end

  def check_string_data
    parsed_data.except("hash").sort.to_h.map { |key, value| "#{key}=#{value}" }.join("\n")
  end

  def bot_token_digest
    OpenSSL::HMAC.digest(digest, "WebAppData", TelegramConfig.bot_credentials)
  end

  def parsed_data
    @parsed_data ||= Rack::Utils.parse_nested_query(init_data)
  end

  def digest
    @digest ||= OpenSSL::Digest.new("SHA256")
  end
end
