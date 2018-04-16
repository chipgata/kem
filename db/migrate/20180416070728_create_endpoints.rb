class CreateEndpoints < ActiveRecord::Migration[5.1]
  def change
    create_table :endpoints do |t|
      t.string :name
      t.text :description
      t.integer :port
      t.string :part
      t.string :status
      t.string :check_protocol
      t.integer :response_timeout
      t.integer :check_interval
      t.integer :unhealthy_threshold
      t.integer :healthy_threshold
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end
end
