class Admin::BotNotificationsController < Admin::BaseController
  def create
    Admin::BotNotificationsWorker.perform_async(user_ids, prepared_message)
    @flash_message = 'Sending a notification has been successfully added to the queue'
    @bot_notification = bot_notification_params
    render :new
  end

  private

  def prepared_message
    {
      ru: bot_notification_params[:message_ru],
      en: bot_notification_params[:message_en]
    }
  end

  def user_ids
    if bot_notification_params[:send_type] == 'everyone'
      User.where(unsubscribed_at: nil).pluck(:chat_id)
    else
      [bot_notification_params[:chat_id]]
    end
  end

  def bot_notification_params
    @bot_notification_params ||= params.require(:bot_notification).permit(:send_type, :chat_id, :message_en, :message_ru)
  end
end
