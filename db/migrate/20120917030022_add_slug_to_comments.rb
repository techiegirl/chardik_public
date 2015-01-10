class AddSlugToComments < ActiveRecord::Migration
  def change
    add_column :comments, :slug, :string, :null => false
    add_index :comments, :slug, :unique => true
  end
end
