class Middleware
  def initialize(app, options)
    @app = app
    @options = options
    @remaining = options[:limit]
    @reset_at = Time.now + options[:reset_in]
  end

  def call(env)
    if @reset_at - Time.now < 0
      @remaining = @options[:limit]
      @reset_at += @options[:reset_in]
    end
    if @remaining > 0
      @remaining -= 1
      response = @app.call(env)
      response[1]["X-RateLimit-Limit"]     = @options[:limit]
      response[1]["X-RateLimit-Remaining"] = @remaining
      response[1]["X-RateLimit-Reset"]     = @reset_at
      response
    else
      Rack::MockResponse.new(429, { "Content-Type" => "text-html" }, "Too Many Requests")
    end
  end
end
