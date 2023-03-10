class DaoProposalVotesController < ApplicationController
  def index
    votes = dao_proposal.votes.includes(:punk)
    votes = votes.where(state: params[:filter]) if params[:filter].present?

    render json: DaoProposalVoteBlueprint.render(votes)
  end

  def create
    punk =  Punk.joins(:user).first

    vote = dao_proposal.votes.new(permitted_params.merge(punk: punk))
    if vote.save
      render json: DaoProposalVoteBlueprint.render(vote)
    else
      head :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:vote).permit(:state)
  end

  def dao_proposal
    @dao_proposal ||= DaoProposal.find(params[:dao_proposal_id])
  end
end
