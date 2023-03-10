class Telegram::Callback::Arena::Base < Telegram::Callback
  include RedisHelper

  delegate :wallet, to: :user

  def choose_game_visibility
    buttons = [
      TelegramButton.new(
        text: I18n.t("cyber_arena.game_visibility.private"),
        data: action_data("create_game:visibility=private")
      ),
      TelegramButton.new(
        text: I18n.t("cyber_arena.game_visibility.public"),
        data: action_data("create_game:visibility=public")
      ),
      back_button
    ]

    update_inline_keyboard(photo: start_fight_photo, buttons: buttons)
  end

  def join_game
    RockPaperScissorsGames::Queue.remove(callback_arguments["game_id"])
    join_result = RockPaperScissorsGames::JoinGame.call(user: user, game_id: callback_arguments["game_id"])

    if join_result.success?
      update_inline_keyboard(photo: start_fight_photo, buttons: []) if message_to_update?
      start_fight(join_result)
    else
      find_game(join_result.error)
    end
  end

  def find_game(caption = "")
    page = callback_arguments["page"].to_i
    games = find_games_scope
    total = games.count
    buttons = games.offset(8 * page).limit(8).map do |game|
      [TelegramButton.new(text: find_game_name(game),
        data: action_data("join_game:page=#{page};game_id=#{game.id}"))]
    end

    min_page = [page - 1, 0].max
    last_page = [(total / 8.0).ceil - 1, 0].max
    max_page = [last_page, page + 3].min
    pages = (min_page..max_page).to_a.push(last_page).uniq
    pages_buttons = pages.map do |i|
      text = i == page ? "•#{i}•" : i
      TelegramButton.new(text: text, data: action_data("find_game:page=#{i}"))
    end

    buttons << pages_buttons
    buttons << [back_button]

    send_or_update_inline_keyboard(photo: start_fight_photo, caption: caption, buttons: buttons)
  end

  def cancel_search
    RockPaperScissorsGames::Queue.remove(callback_arguments["game_id"])
    user&.unlock_game_creation!

    after_cancel_search if RockPaperScissorsGame.created.find_by(id: callback_arguments["game_id"])&.destroy!

    send_matchmaking_invites
  end

  def wait_for_game(game = nil)
    game = game.presence || callback_arguments["game"]

    type = wait_for_game_type_message(game)
    caption = I18n.t("cyber_arena.wait_for_game.share_game", type: type)

    buttons = wait_for_game_default_buttons(game.id)

    result = send_or_update_inline_keyboard(photo: finding_game_photo, caption: caption, buttons: buttons)
    search_message_storage.set(game.id, result.try(:dig, "result", "message_id"))
  end

  def wait_with_proposed_game(game = nil, proposed_game = nil)
    game = game.presence || callback_arguments["game"]
    proposed_game = proposed_game.presence || callback_arguments["proposed_game"]

    type = wait_with_proposed_game_caption_message(game, proposed_game)
    caption = I18n.t("cyber_arena.wait_for_game.share_game", type: type)

    buttons = [
      [TelegramButton.new(
        text: wait_with_proposed_game_accept_message(proposed_game),
        data: action_data("accept_proposed:g_id=#{game.id};p_id=#{proposed_game.id}")
      )],
      [TelegramButton.new(
        text: wait_with_proposed_game_reject_message,
        data: action_data("reject_proposed:game_id=#{game.id}")
      )]
    ] + [wait_for_game_default_buttons(game.id)]

    send_or_update_inline_keyboard(photo: finding_game_photo, caption: caption, buttons: buttons)
  end

  def accept_proposed
    RockPaperScissorsGames::Queue.remove(callback_arguments["g_id"])
    user&.unlock_game_creation!
    RockPaperScissorsGame.created.find_by(id: callback_arguments["g_id"])&.destroy!

    RockPaperScissorsGames::Queue.remove(callback_arguments["p_id"])
    join_result = RockPaperScissorsGames::JoinGame.call(user: user, game_id: callback_arguments["p_id"])

    if join_result.success?
      update_inline_keyboard(photo: start_fight_photo, buttons: []) if message_to_update?
      start_fight(join_result)
    else
      find_game(join_result.error)
    end

    send_matchmaking_invites
  end

  def reject_proposed
    wait_for_game(RockPaperScissorsGame.find_by(id: callback_arguments["game_id"]))
  end

  protected

  def wait_for_game_type_message(_data)
    raise NotImplementedError
  end

  private

  def after_cancel_search
    Telegram::Callback::CyberArena.call(user: user, telegram_request: telegram_request, step: :menu)
  end

  def wait_for_game_default_buttons(game_id)
    [
      TelegramButton.new(text: I18n.t("cyber_arena.wait_for_game.share"), switch_inline_query: ""),
      TelegramButton.new(
        text: I18n.t("cyber_arena.wait_for_game.cancel_search"),
        data: action_data("cancel_search:game_id=#{game_id}")
      )
    ]
  end

  def start_fight(join_result)
    game = join_result.game
    creator_versus_image = join_result.creator_versus_image
    opponent_versus_image = join_result.opponent_versus_image

    Telegram::Callback::Fight.call(user: game.opponent, game: game, versus_image: opponent_versus_image,
      step: :new_game)
    Telegram::Callback::Fight.call(user: game.creator, game: game, versus_image: creator_versus_image, step: :new_game)
  end

  def action_data(data)
    "##{self.class.name.tableize.sub("telegram/callback/", "")}###{data}"
  end

  def send_matchmaking_invites
    RockPaperScissorsGames::Matchmaking::SendInvitesWorker.perform_async
  end

  def search_message_storage
    @search_message_storage ||= RockPaperScissorsGames::Matchmaking::SearchMessageStorage.new
  end

  def back_menu_button
    TelegramButton.new(text: I18n.t("common.back"), data: "#cyber_arena##menu:")
  end

  def back_button
    TelegramButton.new(text: I18n.t("common.back"), data: action_data("menu:"))
  end

  def finding_game_photo
    File.open(TelegramImage.path("search.png"))
  end

  def start_fight_photo
    File.open(TelegramImage.path("start_fight.png"))
  end
end
