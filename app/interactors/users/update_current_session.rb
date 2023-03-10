class Users::UpdateCurrentSession
  include Interactor
  include RedisHelper

  delegate :user, to: :context

  def call
    with_lock "session-update-#{user.id}" do |locked|
      if locked
        session = user.sessions.open.first || user.sessions.create!
        session.touch
      end
    end
  end
end
