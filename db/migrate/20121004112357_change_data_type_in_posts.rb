class ChangeDataTypeInPosts < ActiveRecord::Migration
  def self.up
    change_column :posts, :user_id, :bigint
    change_column :posts, :anonymous, :boolean, :default => false, :null => false
    statement1 = "ALTER TABLE `posts` CHANGE `id` `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    ActiveRecord::Base.connection.execute(statement1)
    statement2 = "ALTER TABLE `users` CHANGE `id` `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT"
    ActiveRecord::Base.connection.execute(statement2)
    
  end
  
  def self.down
    change_column :posts, :id, :int
    change_column :posts, :user_id, :int
    change_column :posts, :anonymous, :boolean, :default => 0, :null => false
    change_column :users, :id, :int
  end
end
