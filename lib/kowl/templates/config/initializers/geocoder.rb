# frozen_string_literal: true

if defined?(Geocoder)
  Geocoder.configure(
    ip_lookup: :geoip2,
    geoip2: {
      file: Rails.root.join('db', 'maxmind/GeoLite2-City.mmdb')
    }
  )
end
