# frozen_string_literal: true

require "rails_helper"

RSpec.describe Telegram::Callback::Arena::FreeBattle do
  let(:telegram_request) { build_telegram_callback_query(data: data) }
  let(:user) { create :user }
  let(:data) { "#arena/free_battle###{step}" }
  let(:callback_arguments) { {} }

  subject(:call) do
    I18n.locale = user.locale
    described_class.call(user: user, telegram_request: telegram_request, step: step,
      callback_arguments: callback_arguments)
  end

  describe "menu" do
    let(:user) { create :user }
    let(:step) { "menu" }

    before { stub_telegram }

    specify do
      expect { call }.to change { RockPaperScissorsGame.count }.by(1)
    end

    context "when one game is already started" do
      before do
        create :rock_paper_scissors_game, creator: user, opponent: nil, state: :started
      end

      specify do
        expect(TelegramApi).to receive(:send_message)
          .with(hash_including(text: "У тебя только две руки. И обе заняты в бою"))

        call
      end
    end

    context "when one game is already created" do
      before do
        create :rock_paper_scissors_game, creator: user, opponent: nil
      end

      specify do
        expect(Telegram::Callback::Fight).to_not receive(:call)
        expect(TelegramApi).to receive(:edit_message)

        call
      end
    end
  end
end
