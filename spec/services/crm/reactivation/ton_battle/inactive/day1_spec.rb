require "rails_helper"

RSpec.describe Crm::Reactivation::TonBattle::Inactive::Day1 do
  subject { described_class.new(user) }

  let(:user) { create(:user) }

  let(:telegram_service) { instance_double(Crm::TelegramService) }

  let(:expected_text) { I18n.t("crm.reactivation.ton_battle.inactive.day1.text") }
  let(:expected_button_text) { I18n.t("crm.reactivation.ton_battle.inactive.day1.button") }
  let(:expected_action) { "#cyber_arena##menu:new_message=true" }
  let(:expected_buttons) { [TelegramButton.new(text: expected_button_text, data: expected_action)] }
  let(:expected_photo) { instance_of(File) }

  before { allow(Crm::TelegramService).to receive(:new).with(user: user).and_return(telegram_service) }

  it { is_expected.to be_executable }

  it "triggers cyber arena invitation" do
    expect(telegram_service).to receive(:send_notification)
      .with(text: expected_text, buttons: expected_buttons, photo: expected_photo)

    expect { subject.perform }.to change(CrmNotification, :count)
  end
end
