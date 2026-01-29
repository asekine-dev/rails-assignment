require "net/http"

module HttpClient
  def self.request(uri, req)
    # uriがhttpsのとき、httpsで通信する。そうでないときは、httpで通信する
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(req)
    end
  end
end
