require 'digest/md5'
require 'fileutils'
require 'yaml'

module WebLoader

  # 以下のようなファイルをキャッシュディレクトリの下に作成。
  # キャッシュディレクトリは絶対パスであることを想定している。
  # __cache__055a266970912bcbd34f88692528c20e.html
  # __cache__055a266970912bcbd34f88692528c20e.yml
  #
  class Cache
    PREFIX = "__cache__"
    #    CACHE_LIMIT = 3600

    def self.basename(url)
      Digest::MD5.hexdigest(url)
    end

    def self.header_filename(dir, url)
      File.join(dir, PREFIX + basename(url) + ".yml")
    end

    def self.content_filename(dir, url)
      File.join(dir, PREFIX + basename(url) + ".html")
    end

    def self.load_content(dir, url)
      header_path = header_filename(dir, url)
      content_path = content_filename(dir, url)
      content = nil
      if FileTest.file?(header_path) && FileTest.file?(content_path)
        content = File.read(content_path)
      end
      content
    end

    def self.write(dir, url, code, content)
      header_path = header_filename(dir, url)
      YAML.dump({"url" => url, "code" => code}, open(header_path, "w"))
      content_path = content_filename(dir, url)
      File.write(content_path, content)
    end

    def self.clear(dir, cache_limit)
      Dir.glob("#{dir}/#{PREFIX}*.{yml,html}").each do |path|
        diff = Time.now - File.mtime(path)
        # 1時間以上昔のキャッシュは使用しない
        too_old_cache = diff > cache_limit
        FileUtils.rm(path) if too_old_cache
      end
    end

  end
end