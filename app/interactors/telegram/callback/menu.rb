class Telegram::Callback::Menu < Telegram::Callback
  CHAT_URLS = {
    ru: "https://t.me/+GafBVkmbBR5jYTg6",
    en: "https://t.me/+Qt0Rtfg0mbFkNjA6"
  }.freeze

  delegate :wallet, to: :user

  def menu
    user.update!(next_step: nil) if user.next_step.present?

    buttons = [
      battle_arena_buttons,
      [button_for(:residential_block), button_for(:black_market)],
      [lootbox_button],
      [button_for(:profile), button_for(:wallet)],
      [button_for(:district49), cyber_arena_chat_button],
      [button_for(:info)]
    ]

    if message_to_update?
      update_inline_keyboard(photo: punk_city_photo, buttons: buttons)
    else
      send_photo_with_keyboard(photo: punk_city_photo, buttons: buttons)
    end
  end

  private

  def battle_arena_buttons
    [button_for(:cyber_arena)].tap do |buttons|
      buttons << button_for(:free_tournaments) if ::FreeTournament.running
    end
  end

  def lootbox_button
    TelegramButton.new(text: I18n.t("black_market.menu.buttons.initial_lootbox"), data: "#initial_lootbox_purchase##menu:")
  end

  def user_participates_in_free_tournament?
    Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT).users.where(id: user.id).any?
  end

  def button_for(type)
    TelegramButton.new(text: I18n.t("menu.#{type}"), data: "##{type}##menu:")
  end

  def cyber_arena_chat_button
    TelegramButton.new(text: I18n.t("menu.cyber_arena_chat"), url: CHAT_URLS[I18n.locale])
  end
end
