# frozen_string_literal: true

require "rails_helper"

RSpec.describe TelegramController do
  before { stub_telegram }

  context "when /start command" do
    let(:params) { build_telegram_request(text: "/start").to_h }

    specify do
      expect do
        post :create, params: params
      end.to(change { User.count }.and(change { UserSession.count }))
    end

    context "when user has no language set up" do
      specify do
        allow_any_instance_of(User).to receive_messages(locale?: false, onboarded?: false)

        expect(Telegram::Callback::Language).to receive(:call)
          .with(user: instance_of(User), telegram_request: instance_of(TelegramRequest), step: :menu)

        post :create, params: params
      end
    end

    context "when user not onboarded" do
      specify do
        allow_any_instance_of(User).to receive_messages(locale?: true, onboarded?: false)

        expect(Telegram::Callback::Onboarding).to receive(:call)
          .with(user: instance_of(User), telegram_request: instance_of(TelegramRequest), step: "step1")

        post :create, params: params
      end
    end
  end

  context "when /cyber_arena command" do
    let(:params) { build_telegram_request(text: "/cyber_arena").to_h }

    specify do
      expect { post :create, params: params }.to change { User.count }.by(1)
    end
  end

  describe "deeplink" do
    let!(:params) { build_telegram_request(text: "/start #{deeplink}").to_h }

    context "invite deeplink" do
      let(:referrer) { create(:user) }
      let(:deeplink) { Deeplinks::Invite.encode(referrer.id) }

      specify do
        expect { post :create, params: params }.to change { User.count }.by(1)

        expect(referrer.referred_users.size).to eq(1)
      end
    end

    context "when utm_source" do
      let(:deeplink) { "utm_source-meduzalive" }

      specify do
        expect { post :create, params: params }.to change { User.count }.by(1)

        expect(User.last.utm_source).to eq("meduzalive")
      end
    end
  end

  context "when update from telegram command" do
    before { stub_telegram }
    let(:user) { create :user, chat_id: 123 }
    let(:params) { build_telegram_update_request(chat_id: "123", status: :kicked).to_h }

    context "when user removed bot" do
      specify do
        expect { post :create, params: params }.to(change { user.reload.unsubscribed_at })
      end
    end

    context "when user added bot back" do
      let(:params) { build_telegram_update_request(chat_id: "123", status: :member).to_h }

      before do
        user.update(unsubscribed_at: Time.current)
      end

      specify do
        post :create, params: params

        expect(user.reload.unsubscribed_at).to be_nil
      end
    end
  end
end
