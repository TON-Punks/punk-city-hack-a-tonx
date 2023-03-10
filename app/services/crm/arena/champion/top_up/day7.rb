class Crm::Arena::Champion::TopUp::Day7 < Crm::Arena::Champion::TopUp::Base
  private

  def previous_notification_type
    Crm::Arena::Champion::TopUp::Day1
  end

  def previous_notification_time_ago
    6.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.top_up.day7.text",
      button_key: "crm.arena.champion.top_up.day7.button",
      action: "#wallet##menu:"
    )
  end
end
