require "rails_helper"

RSpec.describe Crm::Onboarding::Missing::Day1 do
  subject { described_class.new(user) }

  let(:user) { create(:user, locale: locale, onboarded: onboarded) }

  context "when user has no locale set" do
    let(:locale) { nil }
    let(:onboarded) { false }

    it { is_expected.not_to be_executable }
  end

  context "when user has locale set and onboarded" do
    let(:locale) { :ru }
    let(:onboarded) { true }

    it { is_expected.not_to be_executable }
  end

  context "when user has locale set and not onboarded" do
    let(:locale) { :ru }
    let(:onboarded) { false }
    let(:telegram_service) { instance_double(Crm::TelegramService) }

    let(:expected_text) { I18n.t("crm.onboarding.missing.day1.text") }
    let(:expected_button_text) { I18n.t("crm.onboarding.missing.day1.button") }
    let(:expected_action) { "#onboarding##step1" }
    let(:expected_buttons) { [TelegramButton.new(text: expected_button_text, data: expected_action)] }
    let(:expected_photo) { instance_of(File) }

    before { allow(Crm::TelegramService).to receive(:new).with(user: user).and_return(telegram_service) }

    it { is_expected.to be_executable }

    it "triggers onboarding callback" do
      expect(telegram_service).to receive(:send_notification)
        .with(text: expected_text, buttons: expected_buttons, photo: expected_photo)

      expect { subject.perform }.to change(CrmNotification, :count)
    end
  end
end
