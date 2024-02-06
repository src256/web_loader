require 'open-uri'
require 'net/http'
require 'uri'
require 'kconv'

module WebLoader
  class Command
    include WebLoader::Utils

    USER_AGENT = "WebLoader"
    CACHE_DIR = './cache'
    DEFAULT_RETRY = 3
    DEFAULT_REDIRECT = 10
    DEFAULT_SLEEP = 10
    CACHE_LIMIT = 3600 # キャッシュが有効な秒数。デフォルトは1時間とする

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
      @cache_limit = CACHE_LIMIT
    end

    attr_reader :load_cache_page
    attr_accessor :use_cache, :cache_dir, :binary, :user_agent, :verbose
    attr_accessor :cache_limit

    def load_retry(url, retry_count = DEFAULT_RETRY)
      load(url, DEFAULT_REDIRECT, retry_count)
    end

    def load(url, redirect_count = DEFAULT_REDIRECT, retry_count = 0)
      raise ArgumentError, 'HTTP redirect too deep' if redirect_count == 0
      log("Load: #{url}", @verbose)

      ##### キャッシュの読み込み
      @load_cache_page = false
      content = try_load_cache(url)
      if content
        log("Load cache: #{url}", @verbose)
        @load_cache_page = true
        return content
      end

      ##### サーバーからロード
      log("Load server: #{url}", @verbose)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = nil
      begin
        response = http.get(uri.request_uri, 'User-Agent' => @user_agent) # request_uri=path + '?' + query
      rescue Net::ReadTimeout
        # タイムアウトした場合リトライ可能ならばsleepした後に再度ロード実行
        log("Read timeout: #{url}", @verbose)
        if retry_count > 0
          sleep DEFAULT_SLEEP
          return load(url, redirect_count , retry_count - 1)
        end
      end

      ##### レスポンスの処理
      result = nil
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
        result = body
      when Net::HTTPRedirection
        result = load(to_redirect_url(uri, response['location']), redirect_count - 1)
      else
        # 上記以外のレスポンスの場合、リトライ可能ならばsleepした後に再度ロード実行
        if retry_count > 0
          sleep_for = 10
          if response.is_a?(Net::HTTPTooManyRequests)
            # HTTPTooManyRequestsならばretry-afterで指定された値を取得。
            sleep_for = response.header['retry-after'].to_i + 10
            log("Rate limit: #{uri} #{response.header.to_hash} (429 Too Many Requests). Sleeping #{sleep_for} seconds and retry (##{retry_count}).", @verbose)
          else
            log("Unknown response: #{uri} #{response.inspect}. Sleeping #{sleep_for} seconds and retry (##{retry_count}).", @verbose)
          end
          sleep sleep_for
          result = load(url, redirect_count , retry_count - 1)
        end

        # それ以外は対応した例外を発生
        log("error #{url}", true)
        response.value
      end
      result
    end

    private
    def try_load_cache(url)
      return nil unless @use_cache
      Cache.clear(@cache_dir, @cache_limit)
      Cache.load_content(@cache_dir, url)
    end

    def log(msg, put_log)
      puts msg if put_log
    end
  end
end
