require "rails_helper"

RSpec.describe Crm::Arena::Champion::TopUp::Day21 do
  subject { described_class.new(user) }

  let(:user) { create(:user) }

  before { create(:wallet, user: user, virtual_balance: virtual_balance) }

  context "when user's balance is positive" do
    let(:virtual_balance) { 1 }

    it { is_expected.not_to be_executable }
  end

  context "when user's balance is zero" do
    let(:virtual_balance) { 0 }
    let(:telegram_service) { instance_double(Crm::TelegramService) }

    let(:expected_text) { I18n.t("crm.arena.champion.top_up.day21.text") }
    let(:expected_button_text) { I18n.t("crm.arena.champion.top_up.day21.button") }
    let(:expected_action) { "#wallet##menu:" }
    let(:expected_buttons) { [TelegramButton.new(text: expected_button_text, data: expected_action)] }
    let(:expected_photo) { instance_of(File) }

    before { allow(Crm::TelegramService).to receive(:new).with(user: user).and_return(telegram_service) }

    context "when day7 notification not sent" do
      it { is_expected.not_to be_executable }
    end

    context "when day7 notification sent" do
      before do
        create(:crm_notification,
          crm_type: Crm::Arena::Champion::TopUp::Day7.name,
          user: user,
          created_at: 15.days.ago
        )
      end

      it { is_expected.to be_executable }

      it "triggers cyber arena invitation" do
        expect(telegram_service).to receive(:send_notification)
          .with(text: expected_text, buttons: expected_buttons, photo: expected_photo)

        expect { subject.perform }.to change(CrmNotification, :count)
      end
    end
  end
end
