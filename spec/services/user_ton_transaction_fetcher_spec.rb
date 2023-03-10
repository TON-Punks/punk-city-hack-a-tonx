require 'rails_helper'

RSpec.describe UserTonTransactionFetcher do
  subject { described_class.call(from_address: from_address, to_address: to_address, ton_amount: ton_amount) }

  let(:from_address) { 'EQC9gwf-qxtI6mceWeNEtjDJUH9ZRbYpE7WGxjmmRnxyYjqx' }
  let(:to_address) { 'EQDpUkyAa6lZ12P3ZB2PL_rmWwI1I55BU4kxw_rssFL5dswA' }
  let(:ton_amount) { 0.58 }

  around { |e| Timecop.travel(Time.at(1665090539)) { VCR.use_cassette("toncenter/get_transactions", &e) } }

  specify do
    expect(subject).to eq("Tlh2zg+8FieZ/GytdtDU/xy7HxIKWYvE0k0+NwqzVTc=")
  end
end
