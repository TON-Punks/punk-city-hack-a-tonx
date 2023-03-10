# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Telegram::Notifications::NewToadzExperience do
  describe '.call' do
    subject { described_class.call(user: user, exp: exp) }

    let(:user) { create(:user, locale: :ru) }
    let(:exp) { rand(1..100) }

    let(:expected_text) { I18n.t("notifications.new_toadz_experience", exp: exp) }

    before { stub_telegram }

    specify do
      expect(TelegramApi).to receive(:send_message).with(chat_id: user.chat_id, text: expected_text)

      subject
    end
  end
end
