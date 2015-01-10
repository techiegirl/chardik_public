module PagingPagesHelper
  def page_link(userID)
    if current_user.id != userID
      user = User.find(userID)
      status = current_user.following?(user) ? "Unfollow #{user.username}" : "Follow #{user.username}"
      sp_icon = current_user.following?(user) ? "unfollow" : "follow"
      "<i class='icon-#{sp_icon}'></i><a href='/posts/follow?user="+userID.to_s+"' data-remote='true' class='follow"+userID.to_s+"'>#{status}</a>"+
      "<i class='icon-message'></i><a href='/messages'>Send a message to #{user.username}</a>"
      #/users/#{current_user.id}/messages?recipient="+userID.to_s+"
    else
      ""
    end
  end
end
