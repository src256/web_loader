module WebLoader
  module Utils
    UTF_8 = 'UTF-8'

    def detect_charset(str)
      # charsetが指定されていない場合内容からcharsetを判定する
      # https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-22h2 の場合この処理がないと文字化け
      # charsetがサーバーから返されず、ASCII-8BITとして判定される。それをKconv.toutf8で変換すると文字化けする
      # metaタグのcharsetはUTF-8なのでこれを使えば正しいはず
      charset = nil
      # Nokogiriの場合 https://qiita.com/tetoralynx/items/273560ad6f75bb685935
      # <meta\s)(.*)(charset\s*=\s*([\w-]+))(.*)/i
      if str =~ /<meta.*?charset=["']*([^"']+)/i
        charset =  $1
      end
      charset
    end
    # テストのためにmodule_functionを使用
    module_function :detect_charset

    def toutf8_charset(str, charset)
      # charsetが指定されていない場合はnil
      if charset.to_s.length == 0
        charset = detect_charset(str)
      end
      if charset.to_s.length == 0
        return nil
      end

      result = nil
      begin
        # 文字列のcharsetを変更する
        str.force_encoding(charset) # 例外が発生する場合あり。例えば"Shift_JIS"ではなく"Shift-JIS"が渡された場合。
        # force_encodingが失敗した場合はnil
        return nil unless str.valid_encoding?
        result = nil
        if charset =~ /#{UTF_8}/i
          result = str
        else
          # エンコーディングがUTF8じゃない場合変換する
          result = str.encode(UTF_8, invalid: :replace, undef: :replace)
        end
      rescue => ex
        puts ex.message
      end
      result
    end

    def toutf8(str, charset)
      # 2022/04/04(月)
      # GITHUBのアポストロフィ(&#x2019 U+2019)が文字化け問題に対処するために新設。
      # 原因は直接Kconv.toutf8にresponse.bodyをわたしていたことなので(Kconvのguessが失敗していたと思われる)、
      # response.type_paramsを見てそれにforce_encodingすることで対処する。渡されているcharsetとWebページの文字コードが一致していればこれで問題はないはず。
      result = nil
      begin
        # 指定されたcharsetで変換する
        result = toutf8_charset(str.dup, charset)
        # charsetによる変換が失敗した場合Kconvを使用
        result = Kconv.toutf8(str) if result.nil?
      rescue => ex
        puts ex.message
      end
      result
    end

    def to_redirect_url(orig_uri, location)
      redirect_url = location
      if location =~ /^\//
        redirect_url = URI.join(orig_uri, location).to_s
      end
      redirect_url
    end
  end
end