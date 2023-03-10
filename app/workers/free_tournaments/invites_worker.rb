class FreeTournaments::InvitesWorker
  include Sidekiq::Job

  sidekiq_options queue: "low", retry: false

  def perform
    FreeTournaments::SendInviteNotifications.call
  end
end
