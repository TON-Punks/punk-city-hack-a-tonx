# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::FreeGamesCounter do
  let(:counter) { described_class }

  specify do
    counter.increment
    expect(counter.redis.ttl(counter.key)).to be_present
    expect(counter.hit_limit?).to eq(false)
  end

  context 'when above the limit' do
    before { counter.redis.incrby(counter.key, counter::LIMIT ) }

    it { expect(counter.hit_limit?).to eq(true) }
  end
end
