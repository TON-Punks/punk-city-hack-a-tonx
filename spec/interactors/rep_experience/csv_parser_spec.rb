require 'rails_helper'

RSpec.describe RepExperience::CsvParser do
  subject { described_class.call(raw_data: raw_data) }

  let(:raw_data) do
    "5562938152,GG Master,thunderton,1,2022-07-12 18:01:50 UTC,7,0\n5448446196,Bogdanoff,,12,2022-07-29 22:02:13 UTC,69,1"
  end

  let(:expected_result) do
    [
      { chat_id: '5562938152', name: 'GG Master', rep: 0 },
      { chat_id: '5448446196', name: 'Bogdanoff', rep: 1 }
    ]
  end

  specify do
    expect(subject.data).to eq(expected_result)
  end
end
