class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.string :name
      t.jsonb :value
      t.integer :created_by
      t.integer :updated_by
    end
  end
end
