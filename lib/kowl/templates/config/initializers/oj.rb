# frozen_string_literal: true

if defined?(Oj)
  # https://www.rubydoc.info/gems/oj/2.12.11
  # https://www.rubydoc.info/gems/oj/Oj.default_options
  Oj.default_options = { mode: :compat, time_format: :ruby, use_to_json: true }
end