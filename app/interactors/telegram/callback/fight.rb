class Telegram::Callback::Fight < Telegram::Callback
  WEAPONS = %i[katana hack grenade pistol annihilation]

  PERKS_TO_EMOJI = {
    poison: "☢",
    faraday: "🥷",
    force_field: "🔮",
    paracelsus: "💉",
    system_reset: "🔄",
    contusion:  "✅",
    breaker:  "☠",
    blinding_light: "🔦",
    onearmed_bandit: "🔫",
    critical: "🩸",
    miss: "💨",
    vampirism: "💉",
    counter: "⚡"
  }

  include RedisHelper

  def new_game
    user.with_locale do
      versus_image_path = context.versus_image

      buttons = weapons_mapping_for(user).map do |key, text|
        [TelegramButton.new(text: text, data: "#fight###{key}:game_id=#{game.id}")]
      end

      caption = I18n.t('fight.labels.new_game', game_id: game.id)

      if versus_image_path
        versus_image = File.open(versus_image_path)
        send_photo_with_keyboard(photo: versus_image, buttons: [], caption: caption)
      end

      chose_caption = versus_image_path ? "" : "#{caption}\n\n"
      chose_caption += game.user_modifier_descriptions(user)

      send_photo_with_keyboard(photo: choose_photo, buttons: buttons, caption: chose_caption)
    end
  end

  def after_both_moves(game_round_or_game_round_result)
    game_round = game_round_or_game_round_result.respond_to?(:game_round) ? game_round_or_game_round_result.game_round : game_round_or_game_round_result
    result = RockPaperScissorsGames::CreateWeaponsImage.call(game_round: game_round, game: game)

    game.creator.with_locale do
      break if game.creator.bot?
      # sleep(rand(0..7)) if game.opponent&.bot? # Refactor to sidekiq
      path = result.creator_output_path
      caption = game.creator_end_round_message_full(game_round_or_game_round_result)
      send_photo(photo: File.open(path), from: game.creator, caption: caption)
    end

    game&.opponent&.with_locale do
      break if game.opponent.bot?
      # sleep(rand(0..7)) if game.creator.bot?
      path = result.opponent_output_path
      caption = game.opponent_end_round_message_full(game_round_or_game_round_result)
      send_photo(photo: File.open(path), from: game.opponent, caption: caption)
    end

    if game.started?
      new_round
    else
      end_game
    end
  end

  def new_round
    game.creator.with_locale do
      break if game.creator.bot?

      buttons = weapons_mapping_for(game.creator).map do |key, text|
        [TelegramButton.new(text: text, data: "#fight###{key}:game_id=#{game.id}")]
      end
      new_caption = "#{I18n.t("fight.labels.new_round")}\n#{game.creator_health_message}"

      send_photo_with_keyboard(photo: game.creator.weapons_image_url, caption: new_caption, buttons: buttons, from: game.creator)
    end

    game&.opponent&.with_locale do
      break if game.opponent.bot?

      buttons = weapons_mapping_for(game&.opponent).map do |key, text|
        [TelegramButton.new(text: text, data: "#fight###{key}:game_id=#{game.id}")]
      end
      new_caption = "#{I18n.t("fight.labels.new_round")}\n#{game.opponent_health_message}"

      send_photo_with_keyboard(photo: game.opponent.weapons_image_url, caption: new_caption, buttons: buttons, from: game.opponent)
    end
  end

  def end_game
    game.creator.with_locale do
      break if game.creator.bot?

      buttons = if game.boss
        [TelegramButton.new(text: I18n.t("common.back"), data: "#halloween_event##menu:")]
      else
        [TelegramButton.new(text: I18n.t("common.back"), data: "#cyber_arena##menu:new_message=true")]
      end

      creator_image_path = game.need_game_image? ? generated_game_end_images.creator_output_path : free_game_end_image_path(game.creator_won?)

      send_photo_with_keyboard(
        photo: File.open(creator_image_path),
        caption: generated_game_end_caption(game.creator, game.creator_experience, game.creator_won?),
        buttons: buttons,
        from: game.creator
      )
    end

    game&.opponent&.with_locale do
      break if game.opponent.bot?
      buttons = [TelegramButton.new(text: I18n.t("common.back"), data: "#cyber_arena##menu:new_message=true")]

      opponent_image_path = game.need_game_image? ? generated_game_end_images.opponent_output_path : free_game_end_image_path(game.opponent_won?)

      send_photo_with_keyboard(
        photo: File.open(opponent_image_path),
        caption: generated_game_end_caption(game.opponent, game.opponent_experience, game.opponent_won?),
        buttons: buttons,
        from: game.opponent
      )
    end
  end

  WEAPONS.each do |key|
    define_method key do
      return game_closed if !game.started? && !game.created?

      update_inline_keyboard(photo: choose_photo, buttons: [])

      weapon_text = game.boss? ? I18n.t("fight.weapons.halloween.#{key}") : I18n.t("fight.weapons.#{key}")
      your_weapon = I18n.t("fight.labels.your_weapon", weapon: weapon_text)

      send_message(your_weapon)

      move = RockPaperScissorsGame::NAME_TO_MOVE[key]

      game_round_or_game_round_result = with_lock!("rock-paper-scissors-make-move-#{game.id}") do
        game.make_move!(from: user, move: move)
      end

      after_both_moves(game_round_or_game_round_result) if game_round_or_game_round_result.both_moved
    end
  end

  private

  def game_closed
    caption = I18n.t('fight.errors.game_closed')
    send_photo_with_keyboard(photo: punk_city_photo, caption: caption, buttons: [to_main_menu_button])
  end

  def free_game_end_image_path(user_won)
    lost_image = TelegramImage.path("lost.png")
    won_image = TelegramImage.path("won.png")

    user_won ? won_image : lost_image
  end

  def generated_game_end_images
    @generated_game_end_images ||= RockPaperScissorsGames::CreateResultsImage.call(game: game)
  end

  def generated_game_end_caption(user, user_exp_change, user_won)
    actor = user.punk || user

    experience = actor.prestige_expirience
    new_level_threshold = user.new_prestige_level_threshold(actor.prestige_level)

    game_status = user_won ? "won" : "lost"
    game_type = if game.boss?
                  "halloween"
                elsif game.free?
                  "free"
                elsif game.ton_bet_currency?
                  "ton"
                elsif game.praxis_bet_currency?
                  "praxis"
                end

    I18n.t("fight.labels.end_game.#{game_status}.#{game_type}",
      xp_change: user_exp_change,
      next_level: actor.prestige_level + 1,
      exp_left: new_level_threshold - experience,
      game_address: game.address
    )
  end

  def weapons_mapping_for(u)
    game.available_moves(u).each_with_object({}) do |move, hash|
      weapon_name = RockPaperScissorsGame::MOVE_TO_NAME[move]
      emoji = game.cached_weapons[u.id][move].perks&.keys.to_a.map { |perk| PERKS_TO_EMOJI[perk.to_sym] }.join("")
      weapon_text = I18n.t("fight.weapons.#{weapon_name}")
      hash[weapon_name] = "#{weapon_text} #{emoji}"
    end
  end

  def game
    @game ||= (context.game || RockPaperScissorsGame.find(callback_arguments["game_id"])).decorate
  end

  def choose_photo
    user.weapons_image_url
  end

  def choose_move_photo(move)
    path = game.boss ? "#{game.boss}/choose_#{move}.png" : "choose_#{move}.png"
    File.open(TelegramImage.path(path))
  end
end
