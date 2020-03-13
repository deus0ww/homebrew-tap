class Zimg < Formula
  desc "Scaling, colorspace conversion, and dithering library"
  homepage "https://github.com/sekrit-twc/zimg"
  url "https://github.com/sekrit-twc/zimg/archive/release-2.9.3.tar.gz"
  sha256 "a15c0483fbe945ffe695a1a989bc43b3381c8bf33e2d1760464ec21d32cdf30b"
  head "https://github.com/sekrit-twc/zimg.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  # Upstream has decided not to fix https://github.com/sekrit-twc/zimg/issues/52
  depends_on :macos => :el_capitan

  def install
    ENV.append "CFLAGS",      "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CPPFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CXXFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCFLAGS",   "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS",     "-Ofast -flto=thin -march=native -mtune=native -dead_strip"

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <zimg.h>

      int main()
      {
        zimg_image_format format;
        zimg_image_format_default(&format, ZIMG_API_VERSION);
        assert(ZIMG_MATRIX_UNSPECIFIED == format.matrix_coefficients);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lzimg", "-o", "test"
    system "./test"
  end
end
