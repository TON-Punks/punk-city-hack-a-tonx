require "rails_helper"

RSpec.describe Crm::TelegramService do
  describe "#send_notification" do
    subject { described_class.new(user: user).send_notification(text: "test", buttons: [], photo: '/path/image.png') }

    let(:user) { create(:user) }

    it "triggers cyber arena invitation" do
      expect(TelegramApi).to receive(:send_photo)

      subject
    end
  end
end
