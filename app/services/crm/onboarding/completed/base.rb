class Crm::Onboarding::Completed::Base < Crm::Base
  private

  def matches_conditions?
    user.onboarded?
  end
end
