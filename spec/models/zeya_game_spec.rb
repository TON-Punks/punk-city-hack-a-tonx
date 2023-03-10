require 'rails_helper'

RSpec.describe ZeyaGame, type: :model do
  describe 'user_experience' do
    let(:game) { create :zeya_game }

    context 'when score < 5000' do
      before { game.update(score: 4500) }

      it { expect(game.user_experience).to eq(9) }
    end

    context 'when score < 50_000' do
      before { game.update(score: 45_000) }

      it { expect(game.user_experience).to eq(30) }
    end

    context 'when score < 150_000' do
      before { game.update(score: 140_000) }

      it { expect(game.user_experience).to eq(33) }
    end

    context 'when score < 1_500_000' do
      before { game.update(score: 1_000_000) }

      it { expect(game.user_experience).to eq(50) }
    end

    context 'when score > 1_500_000' do
      before { game.update(score: 2_000_000) }

      it { expect(game.user_experience).to eq(64) }
    end
  end
end
