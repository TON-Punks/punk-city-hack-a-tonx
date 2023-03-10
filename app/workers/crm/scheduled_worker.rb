class Crm::ScheduledWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low', retry: false

  SEGMENTS_INTERVAL_MAPPING = {
    Segments::Crm::BEGINNER => 3.days,
    Segments::Crm::REGULAR_FREE => 4.days,
    Segments::Crm::REGULAR_PAYER => 4.days,
    Segments::Crm::CHAMPION_FREE => 1.week,
    Segments::Crm::CHAMPION_PAYER => 1.week,
    Segments::Crm::INACTIVE => 2.days
  }

  MAPPING = {
    Segments::Crm::BEGINNER => [
      Crm::Onboarding::Missing::Day1,
      Crm::Onboarding::Missing::Day4,
      Crm::Onboarding::Missing::Day7,
      Crm::Onboarding::Completed::Day1,
      Crm::Onboarding::Completed::Day4,
      Crm::Onboarding::Completed::Day7
    ],
    Segments::Crm::REGULAR_FREE => [
      Crm::Reactivation::TonBattle::Player::Day1,
      Crm::Reactivation::TonBattle::Player::Day7,
      Crm::Reactivation::TonBattle::Player::Day14,
      Crm::Arena::Regular::TonBattle::Day1,
      Crm::Arena::Regular::TonBattle::Day4,
      Crm::Arena::Regular::TopUp::Day1,
      Crm::Arena::Regular::TopUp::Day4,
      Crm::Arena::Regular::TopUp::Day7,
      Crm::Arena::Regular::TopUp::Day14,
    ],
    Segments::Crm::REGULAR_PAYER => [
      Crm::Reactivation::TonBattle::Player::Day1,
      Crm::Reactivation::TonBattle::Player::Day7,
      Crm::Reactivation::TonBattle::Player::Day14
    ],
    Segments::Crm::CHAMPION_FREE => [
      Crm::Reactivation::TonBattle::Player::Day1,
      Crm::Reactivation::TonBattle::Player::Day7,
      Crm::Reactivation::TonBattle::Player::Day14,
      Crm::Arena::Champion::TonBattle::Day1,
      Crm::Arena::Champion::TonBattle::Day7,
      Crm::Arena::Champion::TopUp::Day1,
      Crm::Arena::Champion::TopUp::Day7,
      Crm::Arena::Champion::TopUp::Day21,
      Crm::Arena::Champion::TopUp::Day28,
    ],
    Segments::Crm::CHAMPION_PAYER => [
      Crm::Reactivation::TonBattle::Player::Day1,
      Crm::Reactivation::TonBattle::Player::Day7,
      Crm::Reactivation::TonBattle::Player::Day14
    ],
    Segments::Crm::INACTIVE => [
      Crm::Reactivation::TonBattle::Inactive::Day1,
      Crm::Reactivation::TonBattle::Inactive::Day4,
      Crm::Reactivation::TonBattle::Inactive::Day7
    ]
  }

  def perform
    MAPPING.each do |segment_name, notifications|
      process_segment(segment_name, notifications) if segment_can_be_notified?(segment_name)
    end
  end

  private

  def process_segment(segment_name, notifications)
    Segments::Crm.fetch(segment_name).users.notifiable.find_each do |user|
      process_user_of_segment(user, notifications) if user.experiment_participant?(AbTestingExperiments::Crm)
    end
  end

  def segment_can_be_notified?(segment_name)
    CrmNotification.where(
      created_at: SEGMENTS_INTERVAL_MAPPING.fetch(segment_name).ago..,
      segment_id: Segments::Crm.fetch(segment_name).id
    ).order(:created_at).blank?
  end

  def process_user_of_segment(user, notifications)
    triggerable_crm = notifications.detect { |crm| crm.new(user).executable? }
    triggerable_crm.new(user).perform if triggerable_crm
  end
end
