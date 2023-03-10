class LootboxesController < ApplicationController
  def index
    render json: LootboxBlueprint.render(user.lootboxes.created)
  end

  def show
    lootbox = Lootbox.find(params[:id])

    render json: LootboxBlueprint.render(lootbox)
  end

  def open
    lootbox = user.lootboxes.created.find_by(id: params[:id])

    result = Lootboxes::Deploy.call(lootbox: lootbox)

    if result.success?
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def user
    @user ||= begin
      User.find_by_auth_token!(params[:token])
    end
  end
end
