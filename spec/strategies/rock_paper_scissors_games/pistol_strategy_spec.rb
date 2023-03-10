# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::PistolStrategy do
  describe '#pick_move' do
    include_examples 'first move strategy', :pistol
  end
end
