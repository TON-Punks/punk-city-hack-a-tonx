# frozen_string_literal: true

require "rails_helper"

RSpec.describe Telegram::Callback::Arena::TonBattle do
  let(:telegram_request) { build_telegram_callback_query(data: data) }
  let(:user) { create :user }
  let(:data) { "#arena/ton_battle###{step}" }
  let(:callback_arguments) { {} }

  subject(:call) do
    I18n.locale = user.locale
    described_class.call(user: user, telegram_request: telegram_request, step: step,
      callback_arguments: callback_arguments)
  end

  describe "find_game" do
    let(:step) { "find_game" }

    before { stub_telegram }

    specify do
      call
    end
  end
end
