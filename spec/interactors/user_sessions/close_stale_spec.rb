# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSessions::CloseStale do
  let!(:session1) { create :user_session, updated_at: 1.minute.ago }
  let!(:session2) { create :user_session, updated_at: 11.minutes.ago }
  let!(:session3) { create :user_session, updated_at: 20.minutes.ago }

  specify do
    described_class.call

    expect(session1.reload).to be_open
    expect(session2.reload).to be_closed
    expect(session3.reload).to be_closed
  end
end
