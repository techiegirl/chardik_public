class AddAnonymousToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :anonymous, :boolean
  end
end
