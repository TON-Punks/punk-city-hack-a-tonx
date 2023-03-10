class UserSessions::CloseStale
  include Interactor
  include RedisHelper

  delegate :user, to: :context

  def call
    UserSession.open.where(updated_at: ..10.minutes.ago).find_each(&:close!)
  end
end
