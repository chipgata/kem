class AddCheckExtendToEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_column :endpoints, :check_extend, :jsonb
  end
end
