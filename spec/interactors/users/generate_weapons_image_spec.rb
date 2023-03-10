# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::GenerateWeaponsImage do
  include AwsHelper

  let(:user) { create :user, :with_default_weapons }

  describe '.call' do
    specify do
      expect(Aws::S3::Client).to receive(:new).and_return(aws_client)
      expect(aws_client).to receive(:put_object)

      described_class.call(user: user)
    end
  end
end
