class AccessKeyToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :access_token, :text
    add_column :users, :token_expired, :datetime
  end
end
