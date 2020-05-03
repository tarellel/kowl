# frozen_string_literal: true

# Use argon instead of bcrypt for devise
# => https://ankane.org/devise-argon2
if defined?(Devise)
  module Argon2Encryptor
    def digest(klass, password)
      if klass.pepper.present?
        password = "#{password}#{klass.pepper}"
      end
      ::Argon2::Password.create(password)
    end

    def compare(klass, hashed_password, password)
      return false if hashed_password.blank?

      if hashed_password.start_with?('$argon2')
        if klass.pepper.present?
          password = "#{password}#{klass.pepper}"
        end
        ::Argon2::Password.verify_password(password, hashed_password)
      else
        super
      end
    end
  end

  Devise::Encryptor.singleton_class.prepend(Argon2Encryptor)
end
