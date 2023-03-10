class Admin::BotNotificationsWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(chat_ids, message)
    localized_messages = message.with_indifferent_access

    User.where(chat_id: chat_ids).find_each do |user|
      user.with_locale do
        Telegram::Notifications::AdminMessage.call(user: user, message: localized_messages[I18n.locale])
      end
    end
  end
end
