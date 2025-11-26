require 'open-uri'
require 'net/http'
require 'uri'
require 'kconv'


module WebLoader
  module Drivers
    class HttpDriver

      def initialize
        @user_agent = nil
        @binary = false
      end

      attr_accessor :user_agent, :binary

      def fetch(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = http.get(uri.request_uri, 'User-Agent' => @user_agent) # request_uri=path + '?' + query
        WebLoader::Response.from_net_http(response, @binary)
      end
    end
  end
end