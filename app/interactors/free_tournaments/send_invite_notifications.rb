class FreeTournaments::SendInviteNotifications
  include Interactor

  def call
    context.fail! if tournament.blank?

    if tournament_started_recently?
      notify_participants(Telegram::Notifications::FreeTournaments::FirstDay)
    elsif tournament_running?
      notify_participants(Telegram::Notifications::FreeTournaments::ThirdDay)
    end
  end

  private

  def notify_participants(notifier_klass)
    participants.find_each { |user| user.with_locale { notifier_klass.call(user: user) } }
  end

  def participants
    Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT).users
  end

  def tournament_scheduled?
    start_at.between?(Time.now.utc, 1.day.from_now)
  end

  def tournament_started_recently?
    start_at.between?(1.day.ago, Time.now.utc)
  end

  def tournament_running?
    start_at.between?(3.days.ago, 2.days.ago)
  end

  def start_at
    @start_at ||= tournament.start_at
  end

  def tournament
    @tournament ||= FreeTournament.running || FreeTournament.scheduled
  end
end
