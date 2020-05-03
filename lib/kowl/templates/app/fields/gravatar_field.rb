# frozen_string_literal: true

require 'digest/md5'
class GravatarField < Administrate::Field::Base
  def gravatar_url
    email_address = data.downcase
    hash = Digest::MD5.hexdigest(email_address)
    "http://www.gravatar.com/avatar/#{hash}"
  end
end
