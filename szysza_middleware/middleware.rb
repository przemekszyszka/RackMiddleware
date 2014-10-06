class Middleware
  def initialize(app, options)
    @app = app
    @options = options
    @left_requests = {}
  end

  def call(env)
    unless @left_requests.has_key?(env["REMOTE_ADDR"])
      @left_requests[env["REMOTE_ADDR"]] = {}
      @left_requests[env["REMOTE_ADDR"]][:remaining] = @options[:limit]
      @left_requests[env["REMOTE_ADDR"]][:reset_at]  = Time.now + @options[:reset_in]
    end

    if @left_requests[env["REMOTE_ADDR"]][:reset_at] - Time.now < 0
      @left_requests[env["REMOTE_ADDR"]][:remaining] = @options[:limit]
      @left_requests[env["REMOTE_ADDR"]][:reset_at] += @options[:reset_in]
    end
    if @left_requests[env["REMOTE_ADDR"]][:remaining] > 0
      @left_requests[env["REMOTE_ADDR"]][:remaining] -= 1
      response = @app.call(env)
      response[1]["X-RateLimit-Limit"]     = @options[:limit]
      response[1]["X-RateLimit-Remaining"] = @left_requests[env["REMOTE_ADDR"]][:remaining]
      response[1]["X-RateLimit-Reset"]     = @left_requests[env["REMOTE_ADDR"]][:reset_at]
      response
    else
      Rack::MockResponse.new(429, { "Content-Type" => "text-html" }, "Too Many Requests")
    end
  end
end
