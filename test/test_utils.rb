require "test_helper"

class TestUtils < Minitest::Test

  def read_file(filename)
    path = File.expand_path(File.dirname(__FILE__) + '/fixtures/files/' + filename)
    puts path
    File.read(path)
  end

  def test_detect_charset
    str = '<meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS">'
    charset = ::WebLoader::Utils::detect_charset(str)
    assert_equal('Windows-31J', charset)

    str = '<meta charset="UTF-8">'
    charset = ::WebLoader::Utils::detect_charset(str)
    assert_equal('UTF-8', charset)
  end

  def test_to_utf8_charset
    str = read_file('win31.html')
    result = ::WebLoader::Utils::toutf8_charset(str, "Shift_JIS")
    #    assert_equal('あいうえお', result)
    puts result

  end
end
