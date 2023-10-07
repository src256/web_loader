module WebLoader
  module Utils
    UTF_8 = 'UTF-8'

    def toutf8_charset(str, charset)
      # charsetが指定されていない場合はnil
      return nil if charset.to_s.length == 0
      # 文字列のcharsetを変更する
      str.force_encoding(charset)
      # force_encodingが失敗した場合はnil
      return nil unless str.valid_encoding?

      result = nil
      if charset =~ /#{UTF_8}/i
        result = str
      else
        # エンコーディングがUTF8じゃない場合変換する
        result = str.encode(UTF_8, invalid: :replace, undef: :replace)
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