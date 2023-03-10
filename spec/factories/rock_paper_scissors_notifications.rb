FactoryBot.define do
  factory :rock_paper_scissors_notification do
    chat_id { "MyString" }
    rock_paper_scissors_game { nil }
    sequence(:message_id) { |n| n }
    locale { "ru" }
  end
end
