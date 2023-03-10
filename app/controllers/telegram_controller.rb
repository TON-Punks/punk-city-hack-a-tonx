class TelegramController < ApplicationController
  COMMANDS = %w[menu wallet profile cyber_arena info start]

  def create
    return head(:ok) if skip_request?
    return update_status(user) if telegram_request.status_update?

    set_locale

    update_user if telegram_request&.message&.from

    Wallets::CreateWallet.call(user: user) if user.wallet.blank?

    if telegram_request.message&.command&.start? && telegram_request.message.command_options
      handle_deeplink
    elsif telegram_request.inline_query.present?
      handle_inline_query
    elsif telegram_request.chosen_inline_result.present?
      handle_chosen_inline_query
    elsif COMMANDS.include?(telegram_request.message&.command)
      if !user.locale?
        handle_language_setup
      elsif !user.onboarded?
        handle_onboarding
      else
        call_command
      end
    elsif telegram_request.callback_query&.data.present? || user.next_step.present?
      handle_callback
    elsif telegram_request.callback_query&.game_short_name.present?
      answer_callback_query
    end

    user.update_current_session!

    head(:ok)
  end

  private

  def set_locale
    I18n.locale = user.locale.presence || I18n.default_locale
  end

  def handle_callback
    callback_data = telegram_request&.callback_query&.data
    data = callback_data || user.next_step

    _, action, step, argument_string = data.match(/#(.*)##(.*):(.*)?/).to_a
    callback_arguments = argument_string.to_s.split(';').each_with_object({}) do |argument, memo|
      key, value = argument.split('=')
      memo[key] = value
    end

    klass =  Telegram::Callback.const_get(action.classify)
    klass.call(user: user, telegram_request: telegram_request, step: step, callback_arguments: callback_arguments)
  end

  def answer_callback_query
    Telegram::AnswerCallbackQuery.call(user: user, telegram_request: telegram_request, game_short_name: telegram_request.callback_query&.game_short_name)
  end

  def handle_language_setup
    Telegram::Callback::Language.call(user: user, telegram_request: telegram_request, step: :menu)
  end

  def handle_onboarding
    Telegram::Callback::Onboarding.call(user: user, telegram_request: telegram_request, step: "step1")
  end

  def call_menu_command
    Telegram::Callback::Menu.call(user: user, telegram_request: telegram_request, step: :menu)
  end

  def call_command
    klass =  Telegram::Callback.const_get(telegram_request.message.command.classify)
    klass.call(user: user, telegram_request: telegram_request, step: :menu)
  end

  def telegram_request
    @telegram_request ||= TelegramRequest.new(params.to_unsafe_hash.deep_symbolize_keys)
  end

  def user
    @user ||= User.find_or_create_by(chat_id: telegram_request.chat_id)
  end

  def update_user
    user.update(
      username: telegram_request.message.from.username,
      first_name: telegram_request.message.from.first_name,
      last_name: telegram_request.message.from.last_name
    )
  end

  def handle_deeplink
    deeplink = telegram_request.message.command_options.first

    if deeplink.include?('utm_source')
      _, source = deeplink.split('-')
      user.update(utm_source: source) if user.utm_source.blank?
      user.onboarded? ? call_menu_command : handle_onboarding
    else
      decoded = JSON.parse(Base64.urlsafe_decode64(deeplink)) rescue {}
      handle_decded_deeplink(decoded)
    end
  end

  def handle_decded_deeplink(decoded)
    type = decoded.dig('type')&.classify
    klass =  Telegram::Deeplink.const_get(type) if type
    if klass.blank?
      user.onboarded? ? call_menu_command : handle_onboarding
    else
      klass.call(user: user, telegram_request: telegram_request, deeplink_arguments: decoded.symbolize_keys)
    end
  end

  def handle_inline_query
    Telegram::InlineQuery.call(telegram_request: telegram_request, user: user)
  end

  def handle_chosen_inline_query
    Telegram::ChosenInlineQuery.call(telegram_request: telegram_request, user: user)
  end

  def skip_request?
    telegram_request.edited_message.present? || \
      telegram_request.from_group? || \
      telegram_request.chat_join_request.present? ||
      telegram_request.chat_id.blank?
  end

  def update_status(user)
    user.update(unsubscribed_at: nil) if telegram_request.new_status.member?
    user.update(unsubscribed_at: Time.current) if telegram_request.new_status.kicked?
  end
end
