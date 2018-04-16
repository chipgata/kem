class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end
end
