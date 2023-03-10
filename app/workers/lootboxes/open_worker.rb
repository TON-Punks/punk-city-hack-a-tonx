class Lootboxes::OpenWorker
  include Sidekiq::Worker

  def perform(lootbox_id)
    lootbox = Lootbox.find(lootbox_id)
    Lootboxes::Open.call(lootbox: lootbox)
  end
end
