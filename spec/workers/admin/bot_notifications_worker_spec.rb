# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BotNotificationsWorker do
  subject(:perform) { described_class.new.perform(chat_ids, message) }

  let(:chat_ids) { [first_user.chat_id, second_user.chat_id, rand(100..10_000)] }

  let(:first_chat_id) { rand(1..10) }
  let(:second_chat_id) { rand(11..20) }

  let(:first_user) { create(:user, chat_id: first_chat_id, locale: :ru) }
  let(:second_user) { create(:user, chat_id: second_chat_id, locale: :en) }

  let(:ru_msg) { 'ru_msg' }
  let(:en_msg) { 'en_msg' }

  let(:message) do
    {
      ru: ru_msg,
      en: en_msg,
    }
  end

  specify do
    expect(Telegram::Notifications::AdminMessage).to receive(:call).with(user: first_user, message: ru_msg)
    expect(Telegram::Notifications::AdminMessage).to receive(:call).with(user: second_user, message: en_msg)

    perform
  end
end
