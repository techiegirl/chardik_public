class AddSlugToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :slug, :string,  :null => false
    add_index :posts, :slug, :unique => true
  end
end
