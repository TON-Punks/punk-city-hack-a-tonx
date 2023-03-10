class Crm::Arena::Champion::TopUp::Day28 < Crm::Arena::Champion::TopUp::Base
  private

  def previous_notification_type
    Crm::Arena::Champion::TopUp::Day21
  end

  def previous_notification_time_ago
    7.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.top_up.day28.text",
      button_key: "crm.arena.champion.top_up.day28.button",
      action: "#wallet##menu:"
    )
  end
end
