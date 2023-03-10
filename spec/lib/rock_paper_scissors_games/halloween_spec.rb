# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::Halloween do
  context 'when total_damage 500' do
    before { described_class.increment_total_damage(500) }

    specify do
      expect(described_class.max_hp).to eq(2500)
      expect(described_class.hp_left).to eq(2000)
      expect(described_class.total_damage).to eq(500)
    end
  end

  context 'when total_damage 2700' do
    before { described_class.increment_total_damage(2700) }

    specify do
      expect(described_class.max_hp).to eq(5000)
      expect(described_class.hp_left).to eq(2300)
      expect(described_class.total_damage).to eq(2700)
    end
  end

  context 'when total_damage 7500' do
    before { described_class.increment_total_damage(7_500) }

    specify do
      expect(described_class.max_hp).to eq(10_000)
      expect(described_class.hp_left).to eq(2_500)
      expect(described_class.total_damage).to eq(7_500)
    end
  end

  context 'when total_damage 15000' do
    before { described_class.increment_total_damage(15_000) }

    specify do
      expect(described_class.max_hp).to eq(25_000)
      expect(described_class.hp_left).to eq(10_000)
      expect(described_class.total_damage).to eq(15_000)
    end
  end

  context 'when total_damage 42000' do
    before { described_class.increment_total_damage(42_000) }

    specify do
      expect(described_class.max_hp).to eq(50_000)
      expect(described_class.hp_left).to eq(8_000)
      expect(described_class.total_damage).to eq(42_000)
    end
  end
end
