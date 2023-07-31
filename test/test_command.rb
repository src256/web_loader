require "test_helper"

class TestWebLoader < Minitest::Test

  def test_load_page
    loader = ::WebLoader::Command.new
    content = loader.load('https://srcw.net')
    puts content
  end

  def test_save_image
    ::WebLoader::Command.save_image('https://srcw.net/wiki/image/pukiwiki.png', 'cache/test.png')
  end
end