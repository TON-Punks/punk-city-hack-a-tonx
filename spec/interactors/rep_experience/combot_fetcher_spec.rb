require 'rails_helper'

RSpec.describe RepExperience::CombotFetcher do
  subject { described_class.call }

  around { |e| VCR.use_cassette("combot/chat_users", &e) }

  specify do
    expect(subject.raw_data).to include("123,GG Master,thunderton,1,2022-07-12 18:01:50 UTC,7,10\n")
  end
end
