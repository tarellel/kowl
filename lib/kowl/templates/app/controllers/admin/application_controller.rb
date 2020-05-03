# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    before_action :ensure_admin!
    impersonates :user
    include Pundit
    include Administrate::Punditize
    include ErrorHandlers

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
    # Used to ensure only superusers and staff members can access the admin dashboards
    def ensure_admin!
      redirect_to root_path, notice: 'Not authorized!' unless current_user.present? && current_user.staff_member?
    end
  end
end
