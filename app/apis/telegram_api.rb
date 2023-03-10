class TelegramApi
  include HTTParty
  base_uri "https://api.telegram.org/bot#{TelegramConfig.bot_credentials}"

  def self.send_message(chat_id:, **options)
    with_error_handing(
      post('/sendMessage', body: { chat_id: chat_id, parse_mode: 'markdown', disable_web_page_preview: true }.merge(options)),
      chat_id: chat_id,
      options: options
    )
  end

  def self.send_photo(chat_id:, **options)
    with_retry do
      with_error_handing(
        post('/sendPhoto', multipart: true, body: { chat_id: chat_id, parse_mode: 'markdown', disable_web_page_preview: true }.merge(options)),
        chat_id: chat_id,
        options: options
      )
    end
  end

  def self.send_animation(chat_id:, **options)
    with_error_handing(
      post('/sendAnimation', multipart: true, body: { chat_id: chat_id, parse_mode: 'markdown', disable_web_page_preview: true }.merge(options)),
      chat_id: chat_id,
      options: options
    )
  end

  def self.delete_message(chat_id:, message_id:)
    post('/deleteMessage', body: { chat_id: chat_id, message_id: message_id })
  end

  def self.edit_message(type: 'text', **options)
    method_name = "/editMessage#{(type || 'text').to_s.capitalize}"

    with_error_handing(
      post(method_name, body: { parse_mode: 'markdown', disable_web_page_preview: true, **options }),
      options: options
    )
  end

  def self.send_chat_action(chat_id:)
    post('/sendChatAction', body: { chat_id: chat_id, action: :typing })
  end

  def self.send_game(chat_id:, game_short_name:, **options)
    post('/sendGame', body: { chat_id: chat_id, game_short_name: game_short_name }.merge(options))
  end

  def self.answer_inline_query(inline_query_id:, results:)
    with_error_handing(
      post('/answerInlineQuery', body: { inline_query_id: inline_query_id, is_personal: true, results: results, cache_time: 0 }),
      options: results
    )
  end

  def self.answer_callback_query(callback_query_id:, url:)
    with_error_handing(post('/answerCallbackQuery', body: { callback_query_id: callback_query_id, is_personal: true, url: url, cache_time: 0 }))
  end

  def self.forward_message(chat_id:, from_chat_id:, message_id:)
    with_error_handing(post('/forwardMessage', body: { chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id }))
  end

  def self.with_retry
    yield
  rescue Errno::ENETUNREACH
    retry
  end

  def self.with_error_handing(response, chat_id: nil, options: nil)
    return response if response.success?

    raise if Rails.env.test?

    Rails.logger.warn(response)
    if Rails.env.production? || Rails.env.staging?
      Honeybadger.notify("Telegram Response Fail: #{response.code}", context: { body: response.body, chat_id: chat_id, options: options })
    end

    response
  end
end
