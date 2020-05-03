# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  # Account should not be create-able, unless someone is explicitly signing up to create an account
  def new?
    false
  end

  def create?
    false
  end

  def show?
    # Admins should be able to see all users
    # Staff members should only be able to see people who aren't superusers
    # And everyone should see records for themselves
    admin? || (staff? && record.role != 'superuser') || (staff_member? && current_user.id == record.id)
  end

  def update?
    # Ensure only superusers can edit other superusers.
    # => This is because we don't want a staff member editing a superuser/manager's account
    # => If the current_user only has the staff as role they can only edit someone who isn't a superuser
    admin? || (staff? && record.role != 'superuser') || (staff_member? && current_user.id == record.id)
  end

  def edit?
    update?
  end

  def destroy?
    # This was added because a user shouldn't be able to delete themselves from the admin dashboard
    admin? && current_user.id != record.id
  end

  def impersonate?
    admin? && current_user.id != record.id
  end
end
