module ArticleVotesHelper
  def display_votes(up_vote, down_vote)
    up = (up_vote == 0 ? up_vote : "+#{up_vote}")
    down = (down_vote == 0 ? down_vote : "-#{down_vote}")
    "#{up} / #{down}"
  end
end
