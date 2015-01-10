class AddInformationToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :website, :string
    add_column :users, :bio, :text
    add_column :users, :avatar, :string
    add_column :users, :birthday, :date
    add_column :users, :gender, :string
    add_column :users, :country, :string
  end
end
