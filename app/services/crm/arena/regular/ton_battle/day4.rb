class Crm::Arena::Regular::TonBattle::Day4 < Crm::Arena::Regular::TonBattle::Base
  private

  def previous_notification_type
    Crm::Arena::Regular::TonBattle::Day1
  end

  def previous_notification_time_ago
    3.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.regular.ton_battle.day4.text",
      button_key: "crm.arena.regular.ton_battle.day4.button",
      action: "#arena/ton_battle##menu:new_message=true"
    )
  end
end
