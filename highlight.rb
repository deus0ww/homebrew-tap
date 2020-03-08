class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.php"
  url "http://www.andre-simon.de/zip/highlight-3.55.tar.bz2"
  sha256 "1df2dcf909af03291b3696ddc66219ef22559d4a1db0fd26400e2fa2a795bcfc"
  head "https://gitlab.com/saalen/highlight.git"

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "deus0ww/tap/luajit"

  def install
    ENV.append "CFLAGS",      "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CPPFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CXXFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCFLAGS",   "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS",     "-Ofast -flto=thin -march=native -mtune=native"

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
