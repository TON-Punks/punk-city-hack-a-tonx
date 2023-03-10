class Crm::Reactivation::TonBattle::Inactive::Day1 < Crm::Reactivation::TonBattle::Inactive::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.reactivation.ton_battle.inactive.day1.text",
      button_key: "crm.reactivation.ton_battle.inactive.day1.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
