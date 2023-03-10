# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::AnnihilationStrategy do
  describe '#pick_move' do
    include_examples 'first move strategy', :annihilation
  end
end
