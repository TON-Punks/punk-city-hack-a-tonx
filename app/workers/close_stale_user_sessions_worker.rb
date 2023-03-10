class CloseStaleUserSessionsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'low'

  def perform
    UserSessions::CloseStale.call
  end
end
