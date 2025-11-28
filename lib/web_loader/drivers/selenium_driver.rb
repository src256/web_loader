module WebLoader
  module Drivers
    class SeleniumDriver < ::WebLoader::Drivers::BaseDriver

      def initialize
        super
        @wait_proc = nil
        @wait_seconds = 3
      end

      attr_accessor :wait_proc
      attr_accessor :wait_seconds

      def fetch(url)
        require 'selenium-webdriver'

        #        puts "SeleniumDriver fetching URL: #{url}"

        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
        options.add_argument("--user-agent=#{@user_agent}") if @user_agent

        begin

          driver = Selenium::WebDriver.for(:chrome, options: options)
          driver.navigate.to url

          wait = Selenium::WebDriver::Wait.new(timeout: 10)

          # ページ全体のロード完了を待つ
          if @wait_proc
            wait.until { @wait_proc.call(driver) }
          else
            sleep @wait_seconds
          end

          content_type = driver.execute_script("return document.contentType;")

          body = @binary ? driver.page_source.b : driver.page_source
          response = WebLoader::Response.new(status: 200,
                                             headers: {
                                               'Content-Type' => content_type
                                             }, body: body)
          response
        ensure
          driver.quit if driver
        end
      end

      private
      def create_response(body)
        # デフォルトは成功200
        status = 200
        # redirected = driver.current_url != original_url
        # status = 300 if redirected # 簡易的にリダイレクト扱い
        new(status: status, headers: {}, body: body)
      end
    end
  end
end