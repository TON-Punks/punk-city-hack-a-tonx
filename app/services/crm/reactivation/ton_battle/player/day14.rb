class Crm::Reactivation::TonBattle::Player::Day14 < Crm::Reactivation::TonBattle::Player::Base
  private

  def previous_notification_type
    Crm::Reactivation::TonBattle::Player::Day7
  end

  def previous_notification_time_ago
    7.days.ago
  end

  def perform_action
    send_notification(
      text_key: "crm.reactivation.ton_battle.player.day14.text",
      button_key: "crm.reactivation.ton_battle.player.day14.button",
      action: "#cyber_arena##menu:new_message=true"
    )
  end
end
