class CreateCheckInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :check_infos do |t|
      t.references :endpoint, index: true, null: false, foreign_key: {to_table: :endpoints, on_delete: :cascade}
      t.integer :unhealthy_count
      t.integer :healthy_count
      t.timestamps
    end
  end
end
