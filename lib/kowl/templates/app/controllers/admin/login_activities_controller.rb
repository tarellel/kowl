# frozen_string_literal: true

module Admin
  class LoginActivitiesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = LoginActivity.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   LoginActivity.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
    def order
      @order ||= Administrate::Order.new(
        params.fetch(resource_name, {}).fetch(:order, 'created_at'),
        params.fetch(resource_name, {}).fetch(:direction, 'desc')
      )
    end
  end
end
