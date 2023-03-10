class Crm::Arena::Champion::TopUp::Day1 < Crm::Arena::Champion::TopUp::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.top_up.day1.text",
      button_key: "crm.arena.champion.top_up.day1.button",
      action: "#wallet##menu:"
    )
  end
end
