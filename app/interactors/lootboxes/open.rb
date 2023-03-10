class Lootboxes::Open
  include Interactor

  delegate :lootbox, to: :context

  def call
    if lootbox.result.present?
      lootbox.done!
      item = Item.build_from_data(lootbox.result['type'].to_sym, lootbox.result['data'].symbolize_keys)
      lootbox.user.items << item
      Telegram::Notifications::OpenLootbox.call(lootbox: lootbox, item_user: lootbox.user.items_users.last)
    else
      Lootboxes::OpenWorker.perform_in(5, lootbox.id)
    end
  end
end
