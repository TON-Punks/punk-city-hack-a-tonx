# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::Queue do
  before { described_class.clear }

  it 'acts as a queue' do
    [10, 25, 45, 55].each { |id| described_class.push(id) }
    described_class.remove(45)

    expect(described_class.pop).to eq('10')
    expect(described_class.pop).to eq('25')
    expect(described_class.pop).to eq('55')
  end
end
