class Base < ApplicationRecord
  self.abstract_class = true
  before_create :update_created_by
  before_update :update_modified_by

  def update_created_by
    self.created_by = current_user_id
    self.updated_by = current_user_id
  end

  def update_modified_by
    self.updated_by = current_user_id
  end

  def current_user_id
    User.current.try(:id)
  end
end
