class DaoController < ApplicationController
  def show
    render json: { dao: { balance: 170.20, user_votes: 0, voters: User.joins(:punk).count, nfts_count: Punk.count } }
  end
end
