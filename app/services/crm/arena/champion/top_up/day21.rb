class Crm::Arena::Champion::TopUp::Day21 < Crm::Arena::Champion::TopUp::Base
  private

  def previous_notification_type
    Crm::Arena::Champion::TopUp::Day7
  end

  def previous_notification_time_ago
    14.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.top_up.day21.text",
      button_key: "crm.arena.champion.top_up.day21.button",
      action: "#wallet##menu:"
    )
  end
end
