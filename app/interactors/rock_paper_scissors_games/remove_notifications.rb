class RockPaperScissorsGames::RemoveNotifications
  include Interactor

  delegate :game, :include_permanent, to: :context

  def call
    game_notifications.each do |notification|
      TelegramApi.delete_message(chat_id: notification.chat_id, message_id: notification.message_id)
    end

    game.notifications.destroy_all
  end

  def game_notifications
    notifications = game.notifications
    notifications = notifications.temporary unless include_permanent
    notifications
  end
end
