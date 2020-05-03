# frozen_string_literal: true

module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_not_found
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    # rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActionView::MissingTemplate do
      render plain: '404 Not found', status: :not_found
    end
    # Pundit Authorization
    rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  end

  private

  def not_authorized
    flash[:alert] = 'You are not authorized to access this page.'
    redirect_to(request.referer || root_path)
  end

  def render_not_found
    render template: 'errors/404', status: :not_found
  end
end
