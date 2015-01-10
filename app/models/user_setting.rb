class UserSetting < ActiveRecord::Base
  belongs_to :user
  attr_accessible :comment_reply, :direct_message, :find_by_email, :new_follower, :user_id
end
