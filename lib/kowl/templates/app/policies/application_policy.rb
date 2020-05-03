# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_user, :record

  def initialize(current_user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless current_user

    @current_user = current_user
    @record = record
  end

  def admin?
    current_user.admin? if current_user.present?
  end

  def staff?
    current_user.staff? if current_user.present?
  end

  # Used to verify if the persons role is set to either superuser or staff
  def staff_member?
    admin? || staff?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
