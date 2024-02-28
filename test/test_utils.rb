require "test_helper"

class TestUtils < Minitest::Test

  def test_detect_charset
    str = '<meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS">'
    charset = ::WebLoader::Utils::detect_charset(str)
    assert_equal('Shift_JIS', charset)

    str = '<meta charset="UTF-8">'
    charset = ::WebLoader::Utils::detect_charset(str)
    assert_equal('UTF-8', charset)
  end
end
