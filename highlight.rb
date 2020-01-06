class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.php"
  url "http://www.andre-simon.de/zip/highlight-3.54.tar.bz2"
  sha256 "8a50a85e94061b53085c6ad8cf110039217dbdd411ab846f9ff934bec7ecd6d0"
  head "https://gitlab.com/saalen/highlight.git"

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "luajit"

  def install
    ENV.append "CXXFLAGS", "-Ofast -flto -march=native -mtune=native"
    ENV.append "CFLAGS",   "-Ofast -flto -march=native -mtune=native"
    ENV.append "LDFLAGS",  "-Ofast -flto -march=native -mtune=native"

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
