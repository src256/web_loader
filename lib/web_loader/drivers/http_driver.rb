require 'open-uri'
require 'net/http'
require 'uri'
require 'kconv'


module WebLoader
  module Drivers
    class HttpDriver < WebLoader::Drivers::BaseDriver

      def fetch(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = http.get(uri.request_uri, 'User-Agent' => @user_agent) # request_uri=path + '?' + query
        create_response(response)
      end

      private
      def create_response(response)
        body = response.body
        unless @binary
          # デフォルトでは ASCII-8BITが帰ってくる。
          # Content-Typeのcharsetとみなす。
          # https://bugs.ruby-lang.org/issues/2567
          encoding = response.type_params['charset']
          body = ::WebLoader::Utils.toutf8(body, encoding)
        end
        ::WebLoader::Response.new(
          status: response.code.to_i,
          headers: response.each_header.to_h,
          body: body
        )
      end
    end
  end
end