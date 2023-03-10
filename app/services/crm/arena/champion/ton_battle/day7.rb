class Crm::Arena::Champion::TonBattle::Day7 < Crm::Arena::Champion::TonBattle::Base
  private

  def previous_notification_type
    Crm::Arena::Champion::TonBattle::Day1
  end

  def previous_notification_time_ago
    6.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.ton_battle.day7.text",
      button_key: "crm.arena.champion.ton_battle.day7.button",
      action: "#arena/ton_battle##menu:new_message=true"
    )
  end
end
