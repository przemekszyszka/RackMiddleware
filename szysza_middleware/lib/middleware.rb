class Middleware
  def initialize(app, options)
    @app = app
    @options = options
    @remaining = options[:limit]
  end

  def call(env)
    @remaining -= 1
    response = @app.call(env)
    response[1]["X-RateLimit-Limit"] = @options[:limit]
    response[1]["X-RateLimit-Remaining"] = @remaining
    response
  end
end
