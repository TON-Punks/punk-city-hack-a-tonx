class Lootboxes::CheckResultWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform
    Lootboxes::CheckResult.call
  end
end
