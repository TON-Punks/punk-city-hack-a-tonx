class Crm::Reactivation::TonBattle::Player::Day1 < Crm::Reactivation::TonBattle::Player::Base
  private

  def perform_action
    send_notification(
      text_key: "crm.reactivation.ton_battle.player.day1.text",
      button_key: "crm.reactivation.ton_battle.player.day1.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
