# frozen_string_literal: true

module Admin
  class UsersController < Admin::ApplicationController
    # This is because we want to allow the admins to log out of user accounts that aren't admins
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = User.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   User.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    # This is used in the users dashboard to limit assigning roles
    # => because an admin should be able to assign any role to any user
    # => but someone with a staff role should not be able to assign themselves or anyone else as an admin

    # Used for setting a default sort for the users
    # => https://github.com/thoughtbot/administrate/issues/442
    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, 'created_at'),
        params.fetch(resource_name, {}).fetch(:direction, 'desc')
      )
    end
  end
end
