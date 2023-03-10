class Telegram::Callback::CyberArena < Telegram::Callback
  include RedisHelper
  include TonHelper

  MENU_BUTTONS = %i[praxis ton free].freeze

  delegate :wallet, to: :user

  def menu
    user.update!(next_step: nil) if user.next_step

    menu_text = I18n.t("cyber_arena.labels.chose_type",
      praxis_balance: user.praxis_balance,
      exp_balance: user.effective_experience)

    buttons = MENU_BUTTONS.map do |key|
      [TelegramButton.new(text: I18n.t("cyber_arena.buttons.#{key}"), data: "#arena/#{key}_battle##menu:")]
    end

    buttons << [to_main_menu_button]

    send_or_update_inline_keyboard(photo: cyber_arena_photo, caption: menu_text, buttons: buttons)
  end

  private

  def cyber_arena_photo
    File.open(TelegramImage.path("cyber_arena.png"))
  end
end
