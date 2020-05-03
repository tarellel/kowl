# frozen_string_literal: true

if defined?(Lockbox)
  Lockbox.master_key = ENV['LOCKBOX_MASTER_KEY']
  BlindIndex.master_key = Lockbox.master_key

  # Set all default encryptions to use xsalsa20 (requires libsodium)
  # https://github.com/ankane/lockbox#xsalsa20
  # https://github.com/ankane/lockbox#padding
  Lockbox.default_options = { algorithm: 'xsalsa20', padding: true }
end