require 'open-uri'
require 'net/http'
require 'uri'
require 'kconv'

module WebLoader
  class Command
    include WebLoader::Utils

    USER_AGENT = "WebLoader"
    CACHE_DIR = './cache'

    def self.save_image(url, file)
      # キャッシュせず単に保存する
      cmd= Command.new
      cmd.use_cache = false
      cmd.binary = true
      content = cmd.load(url)
      File.binwrite(file, content)
    end

    def initialize
      @use_cache = true
      @load_cache_page = false #キャッシュを読み込んだかどうか
      @cache_dir = File.expand_path(CACHE_DIR)
      @user_agent = "#{USER_AGENT}/#{VERSION}"
      @binary = false
      @verbose = false
    end

    attr_reader :load_cache_page
    attr_accessor :use_cache, :cache_dir, :binary, :user_agent, :verbose

    def load(url, limit = 10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      log("Load: #{url}", @verbose)
      @load_cache_page = false
      content = try_load_cache(url)
      if content
        log("Load cache: #{url}", @verbose)
        @load_cache_page = true
        return content
      end
      log("Load server: #{url}", @verbose)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response, = http.get(uri.request_uri, 'User-Agent' => @user_agent) # request_uri=path + '?' + query
      case response
      when Net::HTTPSuccess
        # responseがNet::HTTPSuccessのサブクラスの場合成功とみなし読み込んだ内容を返す
        body = response.body
        unless @binary
          # デフォルトでは ASCII-8BITが帰ってくる。
          # Content-Typeのcharsetとみなす。
          # https://bugs.ruby-lang.org/issues/2567
          encoding = response.type_params['charset']
          body = toutf8(body, encoding)
        end
        if @use_cache
          log("Write cache: #{url}", @verbose)
          Cache.write(@cache_dir, url, response.code, body)
        end
        return body
      when Net::HTTPRedirection
        load(to_redirect_url(uri, response['location']), limit - 1)
      else
        log("error #{url}", true)
        # それ以外は対応した例外を発生
        response.value
      end
    end

    private
    def try_load_cache(url)
      return nil unless @use_cache
      Cache.clear(@cache_dir)
      Cache.load_content(@cache_dir, url)
    end

    def log(msg, put_log)
      puts msg if put_log
    end
  end
end
