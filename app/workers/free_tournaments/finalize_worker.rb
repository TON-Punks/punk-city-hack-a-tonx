class FreeTournaments::FinalizeWorker
  include Sidekiq::Job

  sidekiq_options queue: "low"

  def perform
    FreeTournaments::Finalize.call
  end
end
