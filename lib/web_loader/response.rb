module WebLoader
  class Response
    include WebLoader::Utils


    def self.from_selenium(driver, original_url)

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