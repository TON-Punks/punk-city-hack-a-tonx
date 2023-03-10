# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::CheckTonConnection do
  let(:bridge_data) do
     "\nid: 1676905280720010\ndata: {\"from\":\"8007c092a9a3c09f319564162f4c5b24f1414783350f9f7d668c55a8e9ce1b68\",\"message\":\"UnoQtzoauG1nEC1pZfy8AcepiAamLoxcG6ZlVE17CqldK4TajnjTFXShJxHd1MH7K8LsJXPpQaH9vc6rzQNBSruFqCQWIcKOvG8gXctEiw4R+KH8nWXAU1kPa05abke+vzw9/qmspMgDGxhBgKlsUMVb4791WyqEXUZhvymfW1E=\"}\n\nid: 1676905280720013\ndata: {\"from\":\"ea126d5674ce1e900e82f10a60d8adad7d696767cad2b54c784d86ecadcd2266\",\"message\":\"1qKSBqUhsMaBu/U6iZZE20dVXeNdmCOW3spkHxcaKf5qa5VeIhy19tlL9E/fjd9vgYUwlZaObgQotwIV7NKNtuCnkqySaggH44MXW0UWfAbqwlcRIRCs/c+iEZPIsoGPfvKikzUEo5hZsTQoEUmVjYGBA0jU+qPSEBl69gYNNNjONqSxVahY0mSU383b9FjtufhAr1TagXunTMzpeA2w8Uc18stxRTwnF7mquDi4wRnvRdMyysLec8PV1CZdL9pOy2g/7CKfTAjChbDg5Oh/b6ZD5NdBlCSzYKfPTi26dskL5BHcax7wx2mXrTleEv36PpwnYYyQGUZ0d4pJ9j1zIqySVWh82dMsYRcJ2LvAQcAVfIwfsId9t7aYYuxUcZ83A3oHc+binEyPqnI0lymxsLQFMBIUpeHQz8pI2BXti8vXnsLXGFA0zn3c/I1Rll1AeUGhDAIrTgNCHqlFytFBcmusFJX4CVpfL18EgZ2Q4NLrrjQUuybnswyRAGMFTF0WmT8QtcPr7yBhaOZwv6aizcSHkfBXiO2c2aDo8/6xGytX4ajw+BpZTamLVScwCpm+wFHpOi/1dLqDkfGywxBUnfNMZi5XZjPuOsmRJ2Y9dY2k9Tt0y2X2ESzmg6jyOjjj3t0UtkZ92F9BKzlEbUFAGOUgM43bcMmQSSS5rHd0MWAU5PImXm6znaxluk7DrET1mUwALy5IP/4X6v4dqu3oPDEF5BpTFf+ubGziUZIdZniwrDSXdYXh8mSJ7ajZ6fNFFhv8L7+HHvRlQQ==\"}\n\n"
  end
  let(:ton_connect) do
    double(bridge_events: bridge_data, public_key: '3b914835cb21b53d6a3edd73e590efd6b42c79a7eab965b64c964d7234c98d77', secret_key: 'b81fa7201908a4ecbb6f5a89cd02890ffa83d612a598726ec44084405323e589')
  end
  let(:punk_connection) { create(:punk_connection) }
  let(:user) { punk_connection.user }

  before { allow(TonConnect).to receive(:new).and_return(ton_connect) }

  context "when doesn't have punk" do
    specify do
      expect(PunkConnections::Connect).to_not receive(:call)

      described_class.call(user: user, retries: 0)
    end
  end

  context "when has punk in wallet" do
    before do
      punk_connection.punk.update(owner: "0:5dcb4433c3a866c745fd0031100b6f34701e7e0bd22c6f1014e66f041315cc9c")
      stub_telegram
    end

    specify do
      expect(PunkConnections::Connect).to receive(:call).and_call_original

      described_class.call(user: user, retries: 0)
    end
  end

  context "when bridge data is empty" do
    let(:bridge_data) { "\n" }

    specify do
      expect(Users::CheckTonConnectionWorker). to receive(:perform_in).with(5, user.id, 1)

      described_class.call(user: user, retries: 0)
    end
  end
end
