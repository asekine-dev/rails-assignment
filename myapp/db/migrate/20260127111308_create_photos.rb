class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :user, foreign_key: true, null: false
      t.string :title

      t.timestamps
    end
  end
end
