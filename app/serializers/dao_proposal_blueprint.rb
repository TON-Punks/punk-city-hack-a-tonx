class DaoProposalBlueprint < Blueprinter::Base
  identifier :id

  fields :created_at, :expires_at, :name, :state

  field :votes_approved do |proposal, options|
    options.dig(:votes_counter, [proposal.id, 'approved']).to_i
  end

  field :votes_rejected do |proposal, options|
    options.dig(:votes_counter, [proposal.id, 'rejected']).to_i
  end

  association :punk, name: :creator, blueprint: PunkBlueprint

  view :extended do
    fields :description

    field :cover do |proposal|
      proposal.cover_url
    end
  end
end
