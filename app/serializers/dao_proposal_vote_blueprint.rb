class DaoProposalVoteBlueprint < Blueprinter::Base
  fields :state

  association :punk, name: :creator, blueprint: PunkBlueprint
end
