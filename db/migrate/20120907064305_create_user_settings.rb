class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.boolean :find_by_email
      t.boolean :new_follower
      t.boolean :direct_message
      t.boolean :comment_reply

      t.timestamps
    end
  end
end
