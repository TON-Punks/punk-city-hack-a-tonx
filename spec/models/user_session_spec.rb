require 'rails_helper'

RSpec.describe UserSession, type: :model do
  describe '#close' do
    let(:updated_at) { 10.minutes.ago }
    let(:session) { create :user_session, updated_at: updated_at }

    specify do
      session.close!

      expect(session).to be_closed
      expect(session.closed_at.change(usec: 0)).to eq(updated_at.change(usec: 0))
      expect(session.updated_at.change(usec: 0)).to_not eq(updated_at.change(usec: 0))
    end
  end
end
