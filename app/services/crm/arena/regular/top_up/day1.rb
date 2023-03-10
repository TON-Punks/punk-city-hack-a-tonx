class Crm::Arena::Regular::TopUp::Day1 < Crm::Arena::Regular::TopUp::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.arena.regular.top_up.day1.text",
      button_key: "crm.arena.regular.top_up.day1.button",
      action: "#wallet##menu:"
    )
  end
end
