# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RockPaperScissorsGames::Matchmaking::SearchMessageStorage do
  subject { described_class.new.telegram_request_for(game_id) }

  let(:game_id) { rand(1..100) }

  context "when no message_id in storage" do
    it { is_expected.to be_nil }
  end

  context "when message id was set" do
    let(:message_id) { rand(100..1000) }

    before { described_class.new.set(game_id, message_id) }

    it { expect(subject.callback_query.message.message_id).to eq(message_id) }
  end
end
