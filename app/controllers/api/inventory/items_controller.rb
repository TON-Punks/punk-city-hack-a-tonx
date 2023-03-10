class Api::Inventory::ItemsController < Api::BaseController
  def index
    collection = current_user.items_users.not_disabled.joins(:item).where(item: { type: Items::Weapon.name })

    render json: Inventory::ItemsUserSerializer.render(collection.all, root: :items)
  end
end
