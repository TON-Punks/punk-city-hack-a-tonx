# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::GenerateProfileImage do
  include AwsHelper

  describe '.call' do
    let(:stats) do
      create :rock_paper_scissors_statistic,
        ton_won: 12_000_000_000,
        ton_lost: 1000_000_000,
        games_won: 12,
        games_lost: 0
    end
    let(:user) { stats.user }

    before { user.punk = create(:punk, number: 0) }

    I18n.available_locales.each do |locale|
      context "when locale #{locale}" do
        before { user.update(locale: locale) }

        specify do
          expect(Aws::S3::Client).to receive(:new).and_return(aws_client)
          expect(aws_client).to receive(:put_object)

          described_class.call(user: user.reload)
        end
      end
    end
  end
end
