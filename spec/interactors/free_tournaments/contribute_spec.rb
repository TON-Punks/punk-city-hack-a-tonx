# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::Contribute do
  describe "call" do
    subject { described_class.call(user: user, game: game) }

    let(:user) { create(:user) }
    let(:won) { [true, false].sample }
    let(:game) do
      create(:rock_paper_scissors_game, bet_currency: :ton, bet: 10, creator: user, state: game_state,
        visibility: visibility)
    end
    let(:visibility) { :public }
    let(:game_state) { :creator_won }

    context "when no tournament running" do
      it { is_expected.not_to be_success }
    end

    context "when tournament running" do
      before { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now) }

      context "when user participant" do
        before { user.segments << Segments::FreeTournament.fetch(Segments::FreeTournament::PARTICIPANT) }

        context "when won" do
          let(:game_state) { :creator_won }

          context "when private game" do
            let(:visibility) { :private }

            specify do
              subject
              expect(FreeTournament.running.statistic_for_user(user).score).to eq(0)
              expect(FreeTournament.running.statistic_for_user(user).games_won).to eq(0)
            end
          end

          specify do
            subject
            expect(FreeTournament.running.statistic_for_user(user).score).to eq(7)
            expect(FreeTournament.running.statistic_for_user(user).games_won).to eq(1)
          end
        end

        context "when lost" do
          let(:game_state) { :opponent_won }

          context "when private game" do
            let(:visibility) { :private }

            specify do
              subject
              expect(FreeTournament.running.statistic_for_user(user).score).to eq(0)
              expect(FreeTournament.running.statistic_for_user(user).games_won).to eq(0)
            end
          end

          specify do
            subject
            expect(FreeTournament.running.statistic_for_user(user).score).to eq(0)
            expect(FreeTournament.running.statistic_for_user(user).games_lost).to eq(1)
          end
        end
      end

      context "when user not participant" do
        it "calls calibration processor" do
          expect(FreeTournaments::CalibrationProcessor).to receive(:call).with(user: user)
          subject
        end
      end
    end
  end
end
