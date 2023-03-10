# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::KatanaStrategy do
  describe '#pick_move' do
    include_examples 'first move strategy', :katana
  end
end
