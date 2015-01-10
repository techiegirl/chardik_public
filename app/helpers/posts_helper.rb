module PostsHelper
  def start_or_join(title)
    post = Post.find_by_title(title)
    post.blank? ? "Start Discussion" : "Join Discussion"
  end
end
