class ApplicationController < ActionController::Base
  layout "admin"
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_current_user 

  def set_current_user
    User.current = current_user if current_user
  end
end
