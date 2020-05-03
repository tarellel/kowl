# frozen_string_literal: true

require 'administrate/field/text'
class RichTextAreaField < Administrate::Field::Text
  def to_s
    data
  end
end
