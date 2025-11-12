require "test_helper"

class TestWebLoader < Minitest::Test

  def test_load_page
    loader = ::WebLoader::Command.new
    loader.verbose = true
    content = loader.load('https://srcw.net')
    refute_nil(content)
    #    puts content
  end

  def test_load_retry()
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load_retry('https://srcw.net')
    refute_nil(content)
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
    refute_nil(content)
    #    puts content
  end

  def test_load_win1122h2
    # 何故か文字化けする
    loader = ::WebLoader::Command.new
    loader.verbose = true
    loader.use_cache = false
    content = loader.load('https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-22h2')
    refute_nil(content)
    # puts content
  end

  def test_404_not_found
    loader = ::WebLoader::Command.new
    loader.verbose = false
    loader.use_cache = false
    content = loader.load_retry('https://srcw.net/aaa.html')
    assert_nil(content)
    #    puts content
  end

  def test_sjis
    # loader = ::WebLoader::Command.new
    # loader.verbose = true
    # loader.use_cache = false
    # content = loader.load('SJIS Site')
    # puts content
  end

  def test_load_amazon_monthly
    # # Amazon月替わりセールのURL
    # url = 'https://www.amazon.co.jp/s?i=digital-text&rh=n%3A3550442051&srs=3550442051'
    # loader = ::WebLoader::Command.new
    # loader.verbose = true
    # loader.use_cache = true
    # content = loader.load(url)
    # puts content
  end
end