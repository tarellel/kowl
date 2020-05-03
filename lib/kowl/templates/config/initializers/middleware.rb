# frozen_string_literal: true

Rails.application.config.middleware do |m|
  # enable gzip asset compressing to reduce the page size
  m.use Rack::Deflater

  # enable Rack-Attack to prevent credential stuffing
  m.use Rack::Attack
end