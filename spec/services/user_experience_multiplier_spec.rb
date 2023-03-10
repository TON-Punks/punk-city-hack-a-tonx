# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserExperienceMultiplier do
  describe '.call' do
    subject { described_class.call(user) }

    let(:user) { create(:user, last_match_at: last_match_at) }

    context 'when user has last_match_at' do
      context 'when user had no matches for 4 hours' do
        let(:last_match_at) { 5.hours.ago }

        it 'returns MAX multiplier' do
          expect(subject).to eq(1.5)
        end
      end

      context 'when user had matches during last 4 hours' do
        let(:last_match_at) { 2.hours.ago }

        {
          rand(0..10) => 1.5,
          rand(30..95) => 1,
          rand(110..190) => 0.7,
          rand(110..190) => 0.7,
          rand(210..340) => 0.4,
          rand(210..340) => 0.4,
          rand(360..1000) => 0,
          rand(360..1000) => 0
        }.each do |matches_count, expected_multiplier|
          context "when user has #{matches_count} matches" do
            let(:games_relation) { double(:games_relation) }
            let(:opponent_relation) { double(:opponent_relation) }
            let(:arel_relation) { double(:arel_relation) }

            before do
              allow(RockPaperScissorsGame).to receive(:where).with(creator_id: user.id).and_return(games_relation)
              allow(RockPaperScissorsGame).to receive(:where).with(opponent_id: user.id).and_return(opponent_relation)
              allow(games_relation).to receive(:or).with(opponent_relation).and_return(games_relation)
              allow(RockPaperScissorsGame).to receive(:arel_table).and_return(arel_relation)
              allow(arel_relation).to receive(:[]).with(:created_at).and_return(arel_relation)
              allow(arel_relation).to receive(:gt).with(Time.now.utc.beginning_of_day).and_return(arel_relation)
              allow(games_relation).to receive(:where).with(arel_relation).and_return(games_relation)
              allow(games_relation).to receive(:count).and_return(matches_count)
            end

            it "returns #{expected_multiplier} multiplier" do
              expect(subject).to eq(expected_multiplier)
            end
          end
        end
      end
    end
  end
end
