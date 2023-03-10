class Telegram::Notifications::OpenLootbox < Telegram::Base
  delegate :lootbox, :item_user, to: :context
  delegate :item, to: :item_user
  delegate :user, to: :lootbox

  def call
    user.with_locale do
      result_data = lootbox.result['data']
      transaction_link = "https://tonscan.org/tx/#{lootbox.address}"

      box_name = I18n.t("notifications.open_lootbox.name.#{lootbox.series}")

      content = if item.is_a?(Items::Experience)
                  I18n.t("notifications.open_lootbox.content.experience", amount: item_user.data["quantity"])
                elsif item.is_a?(Items::Praxis)
                  I18n.t("notifications.open_lootbox.content.praxis", amount: item_user.data["quantity"])
                else
                  I18n.t("notifications.open_lootbox.content.item")
                end

      text = I18n.t("notifications.open_lootbox.text",
        id: lootbox.id,
        name: box_name,
        content: content,
        transaction_link: transaction_link
      )

      send_inline_keyboard(text: text, buttons: [[inventory_button]])
    end
  end

  def inventory_button
    TelegramButton.new(text: I18n.t("residential_block.buttons.inventory"), web_app: { url: "#{IntegrationsConfig.frontend_url}?token=#{user.auth_token}" })
  end
end
