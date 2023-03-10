FactoryBot.define do
  factory :ab_testing_experiment_crm, class: "AbTestingExperiments::Crm" do
    type { "AbTestingExperiments::Crm" }
    user
    participates { true }
  end
end
