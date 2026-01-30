class AddNotNullConstraintsToUsersAndPhotos < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false
    change_column_null :photos, :title, false
  end
end
