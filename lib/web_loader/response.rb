module WebLoader
  class Response
    include WebLoader::Utils

    def self.from_net_http(response, binary)
      body = response.body
      unless binary
        # デフォルトでは ASCII-8BITが帰ってくる。
        # Content-Typeのcharsetとみなす。
        # https://bugs.ruby-lang.org/issues/2567
        encoding = response.type_params['charset']
        body = ::WebLoader::Utils.toutf8(body, encoding)
      end
      new(
        status: response.code.to_i,
        headers: response.each_header.to_h,
        body: body
      )
    end

    def self.from_selenium(driver, original_url)
      # デフォルトは成功200
      status = 200
      # redirected = driver.current_url != original_url
      # status = 300 if redirected # 簡易的にリダイレクト扱い
      new(status: status, headers: {}, body: driver.page_source)
    end

    def initialize(status:, headers: {}, body: nil)
      @status  = status.to_i
      @headers = headers || {}
      @body    = body
    end

    attr_reader :status, :headers, :body

    def ok?; (200..299).include?(@status); end
    def redirect?; (300..399).include?(@status); end
    def rate_limited?; @status == 429; end
  end
end