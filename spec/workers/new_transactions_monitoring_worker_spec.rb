# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewTransactionsMonitoringWorker do
  specify do
    expect(NewTransactionsMonitoringTonhub).to receive(:call)

    described_class.new.perform
  end
end
