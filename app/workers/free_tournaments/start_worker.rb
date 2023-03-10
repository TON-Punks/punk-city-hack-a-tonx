class FreeTournaments::StartWorker
  include Sidekiq::Job

  sidekiq_options queue: "low"

  def perform
    FreeTournaments::Create.call
  end
end
