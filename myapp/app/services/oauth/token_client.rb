require "net/http"
require "json"

module Oauth
  class TokenClient
    def exchange_code_for_token!(code:)
      uri = URI(ENV.fetch("OAUTH_TOKEN_URL"))

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/x-www-form-urlencoded"

      req.set_form_data(
        grant_type: "authorization_code",
        code: code,
        redirect_uri: ENV.fetch("OAUTH_REDIRECT_URI"),
        client_id: ENV.fetch("OAUTH_CLIENT_ID"),
        client_secret: ENV.fetch("OAUTH_CLIENT_SECRET")
      )

      res = HttpClient.request(uri, req)

      unless res.is_a?(Net::HTTPSuccess)
        raise "Token exchange failed: status=#{res.code} body=#{res.body}"
      end

      json = JSON.parse(res.body)
      json.fetch("access_token")
    end
  end
end
