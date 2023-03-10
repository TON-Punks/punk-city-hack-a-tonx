class Missions::NeuroboxLevel::Validator
  include Interactor

  MAX_LOOTBOXES = 100

  delegate :user, to: :context

  def call
    context.available = available_for_user
  end

  private

  def available_for_user
    return false if Lootbox.lite_series.count >= 100
    return false if user.lootboxes.lite_series.count >= 5

    true
  end
end
