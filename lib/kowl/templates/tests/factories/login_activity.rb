# frozen_string_literal: true

FactoryBot.define do
  factory :LoginActivity do
    identity { Faker::Internet.email }
    ip { Faker::Internet.ip_v4_address }
    success { Faker::Boolean.boolean }
    user_type { 'User' }
    association :user, factory: :user
  end
end
