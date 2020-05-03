# frozen_string_literal: true

class LoginActivityPolicy < ApplicationPolicy
  def show?
    # Only display all login activity if the current user is an admin
    # => Otherwise if the user is a staff member, only display login activity for everyone who isn't an admin
    # => If somehow a user hits this page, only allow them to see login activity for themselves
    admin? || (staff? && record.user.role != 'superuser') || (staff_member? && current_user.id == record.user_id)
  end

  def index?
    admin? || current_user.id == record.user_id
  end

  # All audit logs should not be modifiable, by any means
  def edit?
    false
  end

  def new?
    edit?
  end

  def create?
    edit?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
