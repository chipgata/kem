class AddTimeCheckToEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_column :endpoints, :last_check, :datetime
    add_column :endpoints, :next_check, :datetime
  end
end
