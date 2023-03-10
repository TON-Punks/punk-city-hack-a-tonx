class Crm::Arena::Regular::TonBattle::Day1 < Crm::Arena::Regular::TonBattle::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.arena.regular.ton_battle.day1.text",
      button_key: "crm.arena.regular.ton_battle.day1.button",
      action: "#arena/ton_battle##menu:new_message=true"
    )
  end
end
