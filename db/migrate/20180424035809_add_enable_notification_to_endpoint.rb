class AddEnableNotificationToEndpoint < ActiveRecord::Migration[5.1]
  def change
    add_column :endpoints, :enable_notification, :boolean
  end
end
