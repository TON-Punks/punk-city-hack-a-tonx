class Crm::Base
  REPEAT_NOTIFICATIONS_PERIOD = 1.month

  def initialize(user)
    @user = user
  end

  def perform
    user.with_locale do
      perform_action
      log_notification
    end
  end

  def executable?
    return false if notification_already_sent?
    return false unless previous_notification_sent?

    matches_conditions?
  end

  protected

  def matches_conditions?
    raise NotImplementedError
  end

  def perform_action
    raise NotImplementedError
  end

  def previous_notification_type
    nil
  end

  def previous_notification_time_ago
    raise NotImplementedError
  end

  private

  attr_reader :user

  def notification_already_sent?
    notification_by_type(self.class.name).any?
  end

  def previous_notification_sent?
    if previous_notification_type.blank?
      true
    else
      notification_by_type(previous_notification_type.name).where(created_at: ..previous_notification_time_ago).any?
    end
  end

  def notification_by_type(crm_type)
    CrmNotification.where(
      user: user,
      segment_id: user_segment_id,
      crm_type: crm_type,
      created_at: REPEAT_NOTIFICATIONS_PERIOD.ago..
    )
  end

  def log_notification
    CrmNotification.create(user: user, crm_type: self.class.name, segment_id: user.segment_for(Segments::Crm)&.id)
  end

  def user_segment_id
    user.segment_for(Segments::Crm)&.id
  end

  def send_notification(text_key:, button_key:, action:)
    text = I18n.t(text_key)
    buttons = [TelegramButton.new(text: I18n.t(button_key), data: action)]
    telegram_service.send_notification(text: text, buttons: buttons, photo: photo)
  end

  def photo
    File.open(TelegramImage.path("crm/battle_#{rand(1..3)}.png"))
  end

  def telegram_service
    @telegram_service ||= Crm::TelegramService.new(user: user)
  end
end
