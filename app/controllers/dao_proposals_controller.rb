class DaoProposalsController < ApplicationController
  def index
    dao_proposals = DaoProposal.all
    votes_counter = DaoProposal.votes_counter

    render json: DaoProposalBlueprint.render(dao_proposals, votes_counter: votes_counter)
  end

  def show
    dao_proposal = DaoProposal.find(params[:id])
    votes_counter = DaoProposal.votes_counter

    render json: DaoProposalBlueprint.render(dao_proposal, view: :extended, votes_counter: votes_counter)
  end

  def create
    result = DaoProposals::Create.call(punk: punk, permitted_params: permitted_params, cover: params.dig(:dao_proposal, :cover))

    if result.success?
      render json: DaoProposalBlueprint.render(result.dao_proposal, view: :extended)
    else
      head :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:dao_proposal).permit(:name, :description)
  end

  def punk
    @punk ||= begin
      User.find_by_auth_token!(params[:token]).punk
    end
  end
end
