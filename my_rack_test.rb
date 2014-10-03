require "rubygems"
require "rack/test"
require 'minitest/autorun'
require './app.rb'
require './middleware.rb'


class MyRackTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    @app = App.new
    @middleware = Middleware.new(@app, { "limit" => 60 })
  end

  def test_app_returns_an_response
    assert_equal ["200", {"Content-Type" => "text-html"}, ["Test \n"]], @app.call({})
  end

  def test_header_has_x_retelimit_limit_in
    assert @middleware.call({})[1].has_key?("X-RateLimit-Limit")
  end

  def test_x_retelimit_limit_header_has_value_specified
    assert_equal 60, @middleware.call({})[1]["X-RateLimit-Limit"]
  end
end
