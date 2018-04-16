class AddCategoryRefToEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_reference :endpoints, :category, foreign_key: true
  end
end
