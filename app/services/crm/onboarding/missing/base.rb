class Crm::Onboarding::Missing::Base < Crm::Base
  private

  def matches_conditions?
    user.locale.present? && !user.onboarded?
  end
end
