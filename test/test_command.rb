require "test_helper"

class TestWebLoader < Minitest::Test

  def test_load_page
    loader = ::WebLoader::Command.new
    loader.verbose = true
    content = loader.load('https://srcw.net')
    #    puts content
  end

  def test_load_retry()
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load_retry('https://srcw.net')
    #    puts content
  end

  def test_save_image
    ::WebLoader::Command.save_image('https://srcw.net/wiki/image/pukiwiki.png', 'cache/test.png')
  end

  def test_load_sjis
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load('https://srcw.net')
    #    puts content
  end

  def test_load_win1122h2
    # 何故か文字化けする
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load('https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-22h2')
    # puts content
  end

  def test_404_not_found
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load_retry('https://srcw.net/aaa.html')
    puts content
  end
end