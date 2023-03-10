require 'rails_helper'

RSpec.describe Segments::RecalculationWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(Segments::Recalculator).to receive(:call)

    perform
  end
end
