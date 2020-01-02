class Fribidi < Formula
  desc "Implementation of the Unicode BiDi algorithm"
  homepage "https://github.com/fribidi/fribidi"
  url "https://github.com/fribidi/fribidi/releases/download/v1.0.8/fribidi-1.0.8.tar.bz2"
  sha256 "94c7b68d86ad2a9613b4dcffe7bbeb03523d63b5b37918bdf2e4ef34195c1e6c"
  head "https://github.com/fribidi/fribidi.git"

  def install
    ENV.O3
    ENV.append "CXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS", "-Ofast -flto=thin"
  
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make", "install"
  end

  test do
    (testpath/"test.input").write <<~EOS
      a _lsimple _RteST_o th_oat
    EOS

    assert_match /a simple TSet that/, shell_output("#{bin}/fribidi --charset=CapRTL --test test.input")
  end
end
