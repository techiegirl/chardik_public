class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  acts_as_votable
  has_many :comments
  belongs_to :user
  attr_accessible :title, :user_id, :comments_attributes, :anonymous, :updated_at
  accepts_nested_attributes_for :comments
  validates :title, :presence => true
end
