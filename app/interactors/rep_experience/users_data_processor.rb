class RepExperience::UsersDataProcessor
  include Interactor

  delegate :data, to: :context

  def call
    data.each do |user_data|
      process_user(user_data[:user], user_data[:rep_change], user_data[:exp_to_add])
    end
  end

  private

  def process_user(user, rep_change, exp_to_add)
    ApplicationRecord.transaction do
      user.add_experience!(exp_to_add)
      user.increment!(:chat_rep, rep_change)

      user.with_locale { Telegram::Notifications::ChatRepRewarded.call(user: user, rep: rep_change, exp: exp_to_add) }
    end
  end
end
