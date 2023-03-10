class Missions::NeuroboxLevel::Contributor
  include Interactor

  delegate :user, to: :context

  def call
    return unless Missions::NeuroboxLevel::Validator.call(user: user).available

    mission.increment_levels_count!
    finish_mission if mission.can_be_finished?
  end

  private

  def finish_mission
    mission.update(state: :completed)
    distribute_prize
  end

  def distribute_prize
    purchase = user.black_market_purchases.create!(
      black_market_product: product,
      payment_method: :praxis,
      payment_amount: 0
    )

    Lootbox.create!(black_market_purchase: purchase, series: :lite)
    user.with_locale { Telegram::Notifications::Lootboxes::NeuroboxLevelReceived.call(user: user) }
  end

  def mission
    @mission ||= user.neurobox_level_missions.running.first_or_create!
  end

  def product
    @product ||= BlackMarketProduct.fetch(BlackMarketProduct::AIRDROPPED_LOOTBOX)
  end
end
