RSpec.shared_examples 'first move strategy' do |expected_move|
  context 'when first round' do
    specify do
      game = create :rock_paper_scissors_game
      move = described_class.new(game: game, rounds_count: 0, total_damage: { 'opponent' => 0, 'creator' => 0 }).pick_move

      expect(move).to eq(RockPaperScissorsGame::NAME_TO_MOVE[expected_move])
    end
  end
end
