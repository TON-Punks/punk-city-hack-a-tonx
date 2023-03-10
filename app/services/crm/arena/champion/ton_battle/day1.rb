class Crm::Arena::Champion::TonBattle::Day1 < Crm::Arena::Champion::TonBattle::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.arena.champion.ton_battle.day1.text",
      button_key: "crm.arena.champion.ton_battle.day1.button",
      action: "#arena/ton_battle##menu:new_message=true"
    )
  end
end
