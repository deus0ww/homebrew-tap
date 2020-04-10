class Leptonica < Formula
  desc "Image processing and image analysis library"
  homepage "http://www.leptonica.org/"
  url "http://www.leptonica.org/source/leptonica-1.79.0.tar.gz"
  sha256 "045966c9c5d60ebded314a9931007a56d9d2f7a6ac39cb5cc077c816f62300d8"

  depends_on "pkg-config" => :build

  depends_on "deus0ww/tap/openjpeg"

  depends_on "giflib"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "webp"

  def install
    ENV.append "CFLAGS",      "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CPPFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CXXFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCFLAGS",   "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCXXFLAGS", "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "LDFLAGS",     "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections -dead_strip"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-libwebp
      --with-libopenjpeg
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <leptonica/allheaders.h>

      int main(int argc, char **argv) {
          std::fprintf(stdout, "%d.%d.%d", LIBLEPT_MAJOR_VERSION, LIBLEPT_MINOR_VERSION, LIBLEPT_PATCH_VERSION);
          return 0;
      }
    EOS

    flags = ["-I#{include}/leptonica"] + ENV.cflags.to_s.split
    system ENV.cxx, "test.cpp", *flags
    assert_equal version.to_s, `./a.out`
  end
end
