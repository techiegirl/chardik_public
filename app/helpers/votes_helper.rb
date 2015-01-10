module VotesHelper
  def votesize(idvote,typevote)
    type = typevote
    id = idvote
    if type == "Post"
      @vote = Post.find(id)
    else
      @vote = Comment.find(id)
    end
    render :partial => "votes/votes", :locals => {:vote => @vote}
  end
end
