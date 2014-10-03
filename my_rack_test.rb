require "rubygems"
require "rack/test"
require 'minitest/autorun'
require './app.rb'


class MyRackTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    @app = App.new
    @middleware = Middleware.new(@app)
  end

  def test_app_returns_an_response
    assert_equal ["200", {"Content-Type" => "text-html"}, ["Test \n"]], @app.call("Test env")
  end
end
