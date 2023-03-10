require "rails_helper"

RSpec.describe FreeTournaments::Leaderboard::Generate do
  include AwsHelper

  describe ".call" do
    before { create(:free_tournament, start_at: 1.day.ago, finish_at: 1.day.from_now) }

    specify do
      expect(Aws::S3::Client).to receive(:new).and_return(aws_client)
      expect(aws_client).to receive(:put_object).twice

      described_class.call
    end
  end
end
