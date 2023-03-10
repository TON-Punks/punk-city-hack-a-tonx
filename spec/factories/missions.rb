FactoryBot.define do
  factory :mission do
    user
    state { 1 }
  end

  factory :neurobox_level_mission, parent: :mission, class: Missions::NeuroboxLevelMission
end
