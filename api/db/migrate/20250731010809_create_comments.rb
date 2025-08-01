class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments, id: :string, limit: 25 do |t|
      t.references :post, null: false, foreign_key: true, type: :string
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
