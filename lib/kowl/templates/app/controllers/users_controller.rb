# frozen_string_literal: true

class UsersController < ApplicationController
  include Pundit

  def impersonate
    user = User.find(params[:id])
    authorize user
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to(request.referer || root_path)
  end
end
