class Telegram::ChosenInlineQuery < Telegram::Base
  def call
    RockPaperScissorsNotification.create(
      inline_message_id: telegram_request.chosen_inline_result.inline_message_id,
      rock_paper_scissors_game_id: telegram_request.chosen_inline_result.result_id
    )
  end
end
