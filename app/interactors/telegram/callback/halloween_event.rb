class Telegram::Callback::HalloweenEvent < Telegram::Callback
  delegate :wallet, to: :user

  LEADERS_COUNT = 5

  def menu
    caption = I18n.t('halloween_event.menu.caption',
      tickets_left: tickets_left,
      boss_level: RockPaperScissorsGames::Halloween.level,
      balance: tournament.pretty_balance
    )

    buttons = [
      [TelegramButton.new(text: I18n.t('halloween_event.menu.buttons.leaderboard'), data: '#halloween_event##leaderboard:')],
      [to_main_menu_button]
    ]

    if user.halloween_pass.present?
      if tickets_left > 0
        buttons.unshift([TelegramButton.new(text: I18n.t('halloween_event.menu.buttons.fight'), data: '#halloween_event##fight:')])
      else
        buttons.unshift([TelegramButton.new(text: I18n.t('halloween_event.menu.buttons.tournament_tickets'), data: '#halloween_event##tournament_tickets:')])
      end
    else
      buttons.unshift([TelegramButton.new(text: I18n.t('halloween_event.menu.buttons.battle_pass'), data: '#halloween_event##battle_pass:')])
    end

    update_inline_keyboard(photo: boss_image, caption: caption, buttons: buttons)
  end

  def fight
    game = RockPaperScissorsGame.create(
      creator: user,
      bot: true,
      bot_strategy: RockPaperScissorsGame::FREE_GAMES_STRATEGIES.first,
      boss: :halloween
    ).decorate
    user.tournament_tickets.available.for_tournament(tournament).first.update(rock_paper_scissors_game: game, state: :used)

    image_result = RockPaperScissorsGames::CreateVersusImage.call(game: game)
    game.start!
    Telegram::Callback::Fight.call(user: game.creator, game: game, versus_image: image_result.creator_output_path, step: :new_game)
  end

  def battle_pass
    caption = I18n.t('halloween_event.battle_pass.caption')
    buttons = [
      [TelegramButton.new(text: I18n.t('halloween_event.battle_pass.buttons.purchase'), data: '#halloween_event##purchase_battle_pass:')],
      [TelegramButton.new(text: I18n.t("profile.buttons.wallet"), data: "#wallet##menu:")],
      [back_button]
    ]

    update_inline_keyboard(photo: boss_image, caption: caption, buttons: buttons)
  end

  def tournament_tickets
    buttons = [
      [TelegramButton.new(text: I18n.t("halloween_event.tournament_tickets.buttons.ton_buy"), data: "#halloween_event##purchase_tickets:pay=ton")],
      [TelegramButton.new(text: I18n.t("halloween_event.tournament_tickets.buttons.praxis_buy", praxis_price: product.current_price), data: "#halloween_event##purchase_tickets:pay=praxis")],
      [to_main_menu_button]
    ]

    caption = I18n.t('halloween_event.tournament_tickets.caption',
      praxis_price: product.current_price,
      praxis_balance: user.praxis_balance,
      wallet_balance: user.wallet.pretty_virtual_balance
    )

    if message_to_update?
      update_inline_keyboard(photo: boss_image, caption: caption, buttons: buttons)
    else
      send_inline_keyboard(photo: boss_image, text: caption, buttons: buttons)
    end
  end

  def purchase_tickets
    pay_method = callback_arguments['pay'].to_s

    result = ::BlackMarket::PurchaseHalloweenTickets.call(user: user, pay_method: pay_method)
    buttons = [
      [back_button]
    ]

    text = if result.success?
      I18n.t("halloween_event.purchase_tickets.success")
    else
      text = result.error_message
    end

    if message_to_update?
      update_inline_keyboard(photo: boss_image, caption: text, buttons: buttons)
    else
      send_inline_keyboard(photo: boss_image, text: text, buttons: buttons)
    end
  end

  def purchase_battle_pass
    result = BattlePasses::Buy.call(user: user)

    if result.success?
      buttons = [
        [TelegramButton.new(text: I18n.t('halloween_event.menu.buttons.fight'), data: '#halloween_event##fight:')],
        [back_button]
      ]
      caption = I18n.t('halloween_event.purchase_battle_pass.caption')

      update_inline_keyboard(photo: boss_image, caption: caption, buttons: buttons)
    else
      caption = I18n.t('halloween_event.purchase_battle_pass.error_caption', wallet_address: wallet.pretty_address)
      error_buttons = [
        [TelegramButton.new(text: I18n.t("halloween_event.purchase_battle_pass.buttons.top_up"), data: "#wallet##menu:")],
        [back_button]
      ]

      update_inline_keyboard(photo: boss_image, caption: caption, buttons: error_buttons)
    end
  end

  def leaderboard
    users = User.by_halloween_total_damage.includes(:halloween_statistic).limit(LEADERS_COUNT)
    caption = "#{I18n.t('halloween_event.leaderboard.caption', balance: tournament.pretty_balance)}\n"

    caption += users.map.with_index do |u, i|
      "#{i}. `#{u.identification}` - #{u.halloween_statistic.total_damage}"
    end.join("\n")

    if !caption.include?(user.identification)
      pos = User.joins(:halloween_statistic).where(user_halloween_statistics: { total_damage: (user.halloween_statistic&.total_damage.to_i + 1).. }).count
      extra_caption = "\n#{pos}. `#{user.identification}` - #{user.halloween_statistic&.total_damage.to_i}"
      caption += "\n..." if pos > LEADERS_COUNT
      caption += extra_caption
    end

    buttons = [back_button]

    update_inline_keyboard(photo: leaderboard_photo, caption: caption, buttons: buttons)
  end

  def info
    caption_data = {
      balance: tournament.pretty_balance,
      battle_pass_count: BattlePass.halloween.count,
      fights_count: RockPaperScissorsGame.where(boss: :halloween).count,
      total_damage: RockPaperScissorsGames::Halloween.total_damage,
      boss_hp: RockPaperScissorsGames::Halloween.hp_left,
      boss_max_hp: RockPaperScissorsGames::Halloween.max_hp
    }

    caption = I18n.t('halloween_event.battle_pass.caption', caption_data)
    buttons = [
      [back_button]
    ]

    update_inline_keyboard(photo: boss_image, caption: caption, buttons: buttons)
  end

  private

  def product
    @product ||= BlackMarketProduct.find_by(slug: BlackMarketProduct::HALLOWEEN_TICKETS)
  end

  def back_button
    TelegramButton.new(text: I18n.t('common.menu'), data: '#halloween_event##menu:')
  end

  def boss_image
    boss_level = RockPaperScissorsGames::Halloween.level

    File.open(Rails.root.join("telegram_assets/images/halloween_boss/boss_#{boss_level}.png"))
  end

  def leaderboard_photo
    File.open(TelegramImage.path("halloween_leaderboard.jpg"))
  end

  def tournament
    @tournament ||= Tournament.halloween
  end

  def tickets_left
    @tickets_left ||= user.tournament_tickets.available.for_tournament(tournament).count
  end
end
