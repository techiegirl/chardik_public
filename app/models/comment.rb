class Comment < ActiveRecord::Base
  extend FriendlyId
  friendly_id :comment_text, use: [:slugged, :history]
  belongs_to :post
  belongs_to :user
  has_ancestry
  acts_as_votable
  attr_accessible :parent_id, :comment_text, :post_id, :user_id, :user
  validates :comment_text, :presence => true
end
