class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.php"
  url "http://www.andre-simon.de/zip/highlight-3.56.tar.bz2"
  sha256 "764942e25ebf6b2e07b3efa3bb073e1bb64091d1fd667d6d689091707558fa63"
  head "https://gitlab.com/saalen/highlight.git"

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "deus0ww/tap/luajit"

  def install
    opts = "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    inreplace ["src/makefile"] do |s|
      s.gsub! /^(LUA_PKG_NAME)=(.*)$/, "\\1 = luajit"
    end

    conf_dir = etc/"highlight/" # highlight needs a final / for conf_dir
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}"
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}", "install"
  end

  test do
    system bin/"highlight", doc/"extras/highlight_pipe.php"
  end
end
