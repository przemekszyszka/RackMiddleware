class Middleware
  def initialize(app, options)
    @app = app
    @options = options
  end

  def call(env)
    response = @app.call(env)
    response[1]["X-RateLimit-Limit"] = @options["limit"]
    response
  end
end
