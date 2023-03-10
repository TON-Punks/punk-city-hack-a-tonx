class Inventory::CollectItem
  include Interactor

  delegate :item_user, to: :context
  delegate :user, :item, to: :item_user

  PRAXIS_REWARDS_PROBABILITIES = {
    300 => 55,
    600 => 25,
    900 => 10,
    1200 => 7,
    1500 => 3
  }

  def call
    if item.is_a?(Items::Experience)
      context.quantity = user.effective_prestige_level * 300
      user.add_experience!(context.quantity)
    elsif item.is_a?(Items::Praxis)
      context.quantity = praxis_quantity
      user.praxis_transactions.neurobox_lite.create!(quantity: context.quantity)
    else
      context.fail!
    end
  end

  def praxis_quantity
    choose_weighted_praxis_reward(PRAXIS_REWARDS_PROBABILITIES)
  end

  def choose_weighted_praxis_reward(weighted)
    sum = weighted.inject(0) do |sum, item_and_weight|
      sum += item_and_weight[1]
    end
    target = rand(sum)
    weighted.each do |item, weight|
      return item if target <= weight

      target -= weight
    end
  end
end
