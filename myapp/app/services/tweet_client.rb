require "net/http"
require "json"

class TweetClient
  def initialize(access_token:)
    @access_token = access_token
  end

  def create_tweet!(title:, url:)
    uri = URI(ENV.fetch("TWEET_CREATE_URL"))
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{@access_token}"

    req.body = { text: title, url: url }.to_json

    res = HttpClient.request(uri, req)

    # ステータスコード201 かつ 作成したツイートがJSON形式で返却されると成功
    unless res.code.to_i == 201
      raise "Tweet create failed: status=#{res.code} body=#{res.body}"
    end

    JSON.parse(res.body)
  end
end
