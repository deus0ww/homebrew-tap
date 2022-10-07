class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.php"
  url "http://www.andre-simon.de/zip/highlight-4.2.tar.bz2"
  sha256 "ed3efdb9b416b236e503989f9dfebdd94bf515536cfd183aefe36cefdd0d0468"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/saalen/highlight.git", branch: "master"

  livecheck do
    url "http://www.andre-simon.de/zip/download.php"
    regex(/href=.*?highlight[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "luajit-openresty"

  fails_with gcc: "5" # needs C++17

  def install
    opts = "-Ofast -flto=thin " + (Hardware::CPU.arm? ? "-mcpu=native " : "-march=native -mtune=native ")
    ENV.append "CFLAGS",      opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    inreplace ["src/makefile"] do |s|
      s.gsub!(/^(LUA_PKG_NAME)=(.*)$/, "\\1 = luajit")
    end

    conf_dir = etc/"highlight/" # highlight needs a final / for conf_dir
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}"
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}", "install"
  end

  test do
    system bin/"highlight", doc/"extras/highlight_pipe.php"
  end
end
