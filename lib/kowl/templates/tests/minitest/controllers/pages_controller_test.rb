# frozen_string_literal: true

require 'test_helper'

class PageControllerTest < ActionController::TestCase
  def welcome
    get welcome_path
    assert_response :success
  end
end
