class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts, id: :string, limit: 25 do |t|
      t.string :title
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
