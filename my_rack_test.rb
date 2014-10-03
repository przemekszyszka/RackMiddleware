require "rubygems"
require "rack/test"
require 'minitest/autorun'


class MyRackTest < Minitest::Test
  include Rack::Test::Methods

  def app
    @app = lambda{ return "Test" }
  end

  def test_make_request_to_app
    assert_equal "Test", app.call
  end
end
