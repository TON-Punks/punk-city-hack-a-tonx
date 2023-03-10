# frozen_string_literal: true

require "rails_helper"

RSpec.describe FreeTournaments::InvitesWorker do
  subject(:perform) { described_class.new.perform }

  specify do
    expect(FreeTournaments::SendInviteNotifications).to receive(:call)

    perform
  end
end
