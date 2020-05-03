# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern
  include Pundit

  included do
    # after_action :verify_authorized, unless: :skip_auth_controllers
  end

  def pundit_useies
    current_user
  end

  private

  def skip_auth_controllers
    devise_controller? || controller_path == 'pages'
  end
end
