module Oauth
  # NOTE: stateを利用した真正性確認は行わない
  class AuthorizationUrl
    def to_s
      uri = URI(ENV.fetch("OAUTH_AUTHORIZE_URL"))
      uri.query = URI.encode_www_form(
        response_type: "code",
        client_id: ENV.fetch("OAUTH_CLIENT_ID"),
        redirect_uri: ENV.fetch("OAUTH_REDIRECT_URI"),
        scope: ENV.fetch("OAUTH_SCOPE")
      )
      uri.to_s
    end
  end
end
