# frozen_string_literal: true

require 'rails_helper'

feature 'Signup User' do
  scenario 'with valid credentails' do
    sign_up_user('test@test.com', 'Passw0rd!')

    expect(page).to have_text('Welcome! You have signed up successfully.')
  end

  scenario 'with invalid credentials' do
    sign_up_user('test@test.com', 'password')

    expect(page).to have_text('Password must contain at least one digit')
  end

  def sign_up_user(email, password)
    visit new_user_registration_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    click_button 'Sign up'
  end
end
