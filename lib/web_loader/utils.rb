module WebLoader
  module Utils
    UTF_8 = 'UTF-8'
    def toutf8(str, response_encoding)
      # 2022/04/04(月)
      # GITHUBのアポストロフィ(&#x2019 U+2019)が文字化け問題に対処するために新設。
      # 原因は直接Kconv.toutf8にresponse.bodyをわたしていたことなので(Kconvのguessが失敗していたと思われる)、
      # response.type_paramsを見てそれにforce_encodingすることで対処する。渡されているcharsetとWebページの文字コードが一致していればこれで問題はないはず。
      org_str = str.dup
      result = str
      begin
        if response_encoding.to_s.length > 0 # nilでないかつ長さが0以上
          # responseで指定された文字コードであるとみなす
          str.force_encoding(response_encoding)
          if str.valid_encoding?
            # 指定された文字コードとみなせた場合
            if response_encoding != UTF_8
              # エンコーディングがUTF8じゃない場合返還する
              result = str.encode(UTF_8, invalid: :replace, undef: :replace)
            else
              # UTF8の場合そのまま
              result = str
            end
          else
            # 指定された文字コードとみなせない場合元の文字列を返す
            result = org_str
          end
        else
          # responseで文字コードが指定されていない場合Kconvを使用
          result = Kconv.toutf8(str)
        end
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