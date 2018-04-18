class AddCheckStatusToEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_column :endpoints, :check_status, :string
  end
end
