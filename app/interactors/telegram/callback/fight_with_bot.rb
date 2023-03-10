class Telegram::Callback::FightWithBot < Telegram::Callback
  WEAPONS = %i[katana hack grenade pistol annihilation]

  def new_game
    photo = File.open(TelegramImage.path("choose.png"))
    buttons = weapons_mapping.map do |key, text|
      [TelegramButton.new(text: text, data: "#fight_with_bot###{key}:game_id=#{game.id}")]
    end

    game.start!
    update_inline_keyboard(photo: photo, buttons: buttons, caption: I18n.t('fight.modifier_descriptions'))
  end

  def new_round
    photo = File.open(TelegramImage.path("choose.png"))
    buttons = weapons_mapping.map do |key, text|
      [TelegramButton.new(text: text, data: "#fight_with_bot###{key}:game_id=#{game.id}")]
    end

    new_caption = "#{I18n.t("fight.labels.new_round")}\n#{game.creator_health_message}"

    send_photo_with_keyboard(photo: photo, caption: new_caption, buttons: buttons)
  end

  def end_game
    if !user.onboarded?
      Telegram::Callback::Onboarding.call(user: user, telegram_request: telegram_request, step: :step5)
    end
  end

  WEAPONS.each do |key|
    define_method key do
      chose_photo = File.open(TelegramImage.path("choose_#{key}.png"))
      update_inline_keyboard(photo: chose_photo, caption: I18n.t('fight.modifier_descriptions'), buttons: [])

      your_chose_photo = File.open(TelegramImage.path("#{key}.png"))
      your_weapon = I18n.t("fight.labels.your_weapon", weapon: I18n.t("fight.weapons.#{key}"))

      send_photo(
        photo: your_chose_photo,
        caption: your_weapon
      )

      move = RockPaperScissorsGame::NAME_TO_MOVE[key]

      game_round = game.make_move!(from: user, move: move)

      result = RockPaperScissorsGames::CreateWeaponsImage.call(game_round: game_round, game: game)
      send_photo(photo: File.open(result.creator_output_path), caption: game.creator_end_round_message_full(game_round))

      if game.started?
        new_round
      else
        end_game
      end
    end
  end

  private

  def weapons_mapping
    WEAPONS.each_with_object({}) do |weapon, hash|
      hash[weapon] = I18n.t("fight.weapons.#{weapon}")
    end
  end

  def game
    @game ||= begin
      if (game_id = callback_arguments['game_id'])
        RockPaperScissorsGame.find(game_id)
      else
        RockPaperScissorsGame.create(creator: user, bot: true, bot_strategy: 'random')
      end.decorate
    end
  end
end
