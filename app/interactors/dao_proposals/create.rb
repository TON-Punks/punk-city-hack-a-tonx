class DaoProposals::Create
  include Interactor
  include AwsHelper
  delegate :punk, :permitted_params, :cover, :dao_proposal, to: :context

  def call
    context.dao_proposal = DaoProposal.create!(permitted_params.merge(punk: punk))

    upload_cover if cover.present?
  end

  private

  def upload_cover
    upload_image(folder: :dao_proposals, name: dao_proposal.id, body: cover)
    dao_proposal.update!(has_cover: true)
  end
end
