class Telegram::AnswerCallbackQuery < Telegram::Base
  delegate :game_short_name, to: :context

  def call
    url = send("#{game_short_name.downcase}_url")

    TelegramApi.answer_callback_query(callback_query_id: telegram_request.callback_query.id, url: url)
  end

  private

  def zeya_in_punkcity_url
    url = "https://thesmartnik.github.io/zeya-game/?chat_id=#{user.chat_id}"
    url += "&punk_number=#{user.punk.number}" if user.punk
  end

  def toadz_tournament
    url = "https://thesmartnik.github.io/test-toadz/?chat_id=#{user.chat_id}"
    available_ticket = user.tournament_tickets.available.first
    url += "&tournament_id=#{available_ticket.id}" if available_ticket
  end
end
