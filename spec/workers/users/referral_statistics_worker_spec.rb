require "rails_helper"

RSpec.describe Users::ReferralStatisticsWorker do
  subject { described_class.new.perform }

  let(:first_user) { create(:user) }
  let(:second_user) { create(:user) }

  let(:first_referred_by) { create(:user) }
  let(:second_referred_by) { create(:user) }

  before do
    Referral.create(user: first_referred_by, referred: first_user)
    Referral.create(user: second_referred_by, referred: second_user)

    create(:referral_reward, user: first_referred_by, referral: first_user, experience: 2)
    create(:referral_reward, user: second_referred_by, referral: second_user, experience: 2, created_at: 1.month.ago)
  end

  specify do
    expect(Telegram::Notifications::WeeklyReferralRewards).to receive(:call).with(user: first_referred_by)
    expect(Telegram::Notifications::WeeklyReferralRewards).not_to receive(:call).with(user: second_referred_by)

    subject
  end
end
