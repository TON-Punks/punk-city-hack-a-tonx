class Telegram::Base
  include Interactor
  delegate :telegram_request, :user, to: :context

  private

  def send_message(msg)
    TelegramApi.send_message(chat_id: chat_id, text: msg)
  end

  def send_game(game_short_name)
    TelegramApi.send_game(chat_id: chat_id, game_short_name: game_short_name)
  end

  def send_photo(photo:, caption: '', from: nil)
    TelegramApi.send_photo(chat_id: from&.chat_id || chat_id, photo: photo, caption: caption.to_s)
  end

  def send_photo_with_keyboard(photo:, buttons:, from: nil, caption: '', **options)
    TelegramApi.send_photo(
      chat_id: from&.chat_id || chat_id,
      photo: photo,
      caption: caption.to_s,
      reply_markup: { inline_keyboard: inline_keyboard(Array(buttons)) }.to_json,
      **options
    )
  end

  def send_keyboard(msg, options)
    buttons = options.map { |option| [{ text: option }] }
    TelegramApi.send_message(chat_id: telegram_request.chat_id, text: msg, reply_markup: { keyboard: buttons }.to_json )
  end

  def remove_keyboard(msg = nil)
    options = { reply_markup: { remove_keyboard: true }.to_json }
    options[:text] = msg if msg.present?

    TelegramApi.send_message(chat_id: telegram_request.chat_id, **options)
  end

  def update_inline_keyboard(buttons:, **options)
    if options[:photo] || options[:video] || options[:animation]
      type = :media
      caption = options.delete(:caption).to_s
      caption_entities = options.delete(:caption_entities).to_a
      if options[:photo]
        media_path = options[:photo].is_a?(String) ? options[:photo] : "attach://photo"
        media_args = { type: :photo }
      elsif options[:video]
        media_path = options[:video].is_a?(String) ? options[:video] : "attach://video"
        media_args = { type: :video }
      elsif options[:animation]
        media_path = options[:animation].is_a?(String) ? options[:animation] : "attach://animation"
        media_args = { type: :animation }
      end

      media = media_args.merge(media: media_path, caption: caption, caption_entities: caption_entities, parse_mode: options.fetch(:parse_mode, "markdown").to_s)
      options = options.merge(media: media.to_json)
    end

    TelegramApi.edit_message(
      type: type,
      chat_id: chat_id,
      message_id: telegram_request&.callback_query&.message&.message_id || telegram_request.message.message_id,
      reply_markup: { inline_keyboard: inline_keyboard(Array(buttons)) }.to_json,
      **options
    )
  end

  def send_inline_keyboard(text:, buttons:, photo: nil, **options)
    if photo
      send_photo_with_keyboard(photo: photo, buttons: buttons, caption: text, **options)
    else
      TelegramApi.send_message(
        chat_id: chat_id,
        text: text,
        reply_markup: { inline_keyboard: inline_keyboard(Array(buttons)) }.to_json,
        **options
      )
    end
  end

  def inline_keyboard(buttons)
    keyboard = buttons.map do |button|
      button.respond_to?(:map) ? button.map(&method(:convert_button)) : convert_button(button)
    end
    keyboard.first.is_a?(Array) ? keyboard : [keyboard]
  end

  def convert_button(button)
    attributes = button.attributes.to_h
    attributes.merge!(callback_data: attributes.delete(:data)) if button.data.present?
    attributes
  end

  def message_to_update?
    telegram_request&.callback_query&.message&.message_id
  end

  def chat_id
    telegram_request&.chat_id || user.chat_id
  end
end
