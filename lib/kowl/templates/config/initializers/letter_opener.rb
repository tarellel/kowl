# frozen_string_literal: true

if defined?(LetterOpener)
  LetterOpener.configure do |config|
    # To overrider the location for message storage.
    # Default value is <tt>tmp/letter_opener</tt>
    config.location = Rails.root.join('tmp', 'letter_opener')

    # To render only the message body, without any metadata or extra containers or styling.
    # Default value is <tt>:default</tt> that renders styled message with showing useful metadata.
    config.message_template = :light
  end
end
