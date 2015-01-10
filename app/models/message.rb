class Message < ActiveRecord::Base
  has_ancestry
  is_private_message
  attr_accessible :body, :subject, :recipient, :sender,:recipient_id, :sender_id,:parent_id, :comments_attributes
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  # attr_accessor :to
  
end