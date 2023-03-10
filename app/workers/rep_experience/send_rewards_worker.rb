class RepExperience::SendRewardsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'low', retry: 1, lock: :until_executed, on_conflict: :reject

  def perform
    RepExperience::Organizer.call
  end
end
