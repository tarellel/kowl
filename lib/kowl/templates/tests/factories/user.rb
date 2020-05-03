# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    role { :user }
    password { 'Pa$$w0rd!' }
    password_confirmation { 'Pa$$w0rd!' }
    # password { Faker::Internet.password(min_length: 6, mix_case: true, special_characters: true) }
  end
end
