require "rubygems"
require "rack/test"
require "timecop"
require 'minitest/autorun'
require './szysza_middleware/app.rb'
require './szysza_middleware/middleware.rb'


class MyRackTest < Minitest::Test
  include Rack::Test::Methods

  def app
    middleware = Middleware.new(App.new, { limit: 60, reset_in: 3600 })
  end

  def setup
    get "/"
  end

  def test_app_returns_an_response
    assert_equal "Test", last_response.body
  end

  def test_header_has_x_retelimit_limit_in
    assert last_response.header.has_key?("X-RateLimit-Limit")
  end

  def test_x_retelimit_limit_header_has_value_specified
    assert_equal 60, last_response.header["X-RateLimit-Limit"]
  end

  def test_header_has_x_retelimit_remaining
    assert last_response.header.has_key?("X-RateLimit-Remaining")
  end

  def test_x_retelimit_remaining_value_decreses
    assert_equal 59, last_response.header["X-RateLimit-Remaining"]
    get "/"
    assert_equal 58, last_response.header["X-RateLimit-Remaining"]
  end

  def test_response_returns_too_many_requests_error
    60.times do
      get "/"
    end

    assert_equal 429, last_response.status
    assert_equal "Too Many Requests", last_response.body
  end

  def test_number_of_possible_requests_is_reseted
    current_time = Time.now

    19.times do
      get "/"
    end

    assert_equal 40, last_response.header["X-RateLimit-Remaining"]

    Timecop.travel(current_time + 3600)

    get "/"
    assert_equal 59, last_response.header["X-RateLimit-Remaining"]
  end

  def test_separated_limit_of_requests_for_each_ip
    get "/", {}, "REMOTE_ADDR" => "10.0.0.1"
    get "/", {}, "REMOTE_ADDR" => "10.0.0.1"

    assert_equal 58, last_response.header["X-RateLimit-Remaining"]

    get "/", {}, "REMOTE_ADDR" => "10.0.0.2"

    assert_equal 59, last_response.header["X-RateLimit-Remaining"]
  end
end
