
module WebLoader
  class Downloader

    def self.run(argv)
      STDOUT.sync = true
      opts = {}
      opt = OptionParser.new(argv)
      opt.banner = "Usage: #{opt.program_name} [-h|--help] [Options] <URL> "
      opt.version = WebLoader::VERSION
      opt.separator('')
      opt.separator("Options:")
      opt.on_head('-h', '--help', 'Show this message') do |v|
        puts opt.help
        exit
      end
      opt.on('-v', '--verbose', 'Verbose message') {|v| opts[:v] = v}
      drivers = ['pureruby', 'selenium']
      opt.on('-d DRIVER', '--driver=DRIVER', drivers, drivers.join("|") + "(default pureruby)") {|v| opts[:d] = v }
      opt.on("--disable-cache", "Disable cache") {|v| opts[:disable_cache] = v }
      opt.parse!(argv)
      if argv.empty?
        puts "Error: URL is required."
        puts opt.help
        exit
      end
      command = self.new(opts)
      url = argv[0]
      command.execute(url)
    end

    def initialize(opts)
      @opts = opts
    end

    def execute(url)
      driver = create_driver
      loader = WebLoader::Command.new(driver)
      if @opts[:disable_cache]
        loader.use_cache = false
      end
      loader.load(url)
    end

    private
    def create_driver
      case @opts[:d]
      when 'selenium'
        driver = WebLoader::Drivers::SeleniumDriver.new
        driver.wait_proc = create_wait_proc
      else
        driver = WebLoader::Drivers::HttpDriver.new
      end
      driver
    end

    def create_wait_proc
      # proc do |driver|
      #   # Example wait condition: wait until the document is fully loaded
      #   ready_state = driver.execute_script('return document.readyState')
      #   ready_state == 'complete'
      # end
    end
  end

end