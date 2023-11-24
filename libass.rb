class Libass < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz"
  sha256 "f0da0bbfba476c16ae3e1cfd862256d30915911f7abaa1b16ce62ee653192784"
  license "ISC"

  head do
    url "https://github.com/libass/libass.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz"
  depends_on "libunibreak"

  on_macos do
    depends_on "fontconfig" => :optional
  end

  on_linux do
    depends_on "fontconfig"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    ENV.append "CFLAGS", (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast -flto=thin"

    system "autoreconf", "-i" if build.head?
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-large-tiles
    ]
    # libass uses coretext on macOS, fontconfig on Linux
    args << "--disable-fontconfig" if OS.mac? && (build.without? "fontconfig")
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ass/ass.h"
      int main() {
        ASS_Library *library;
        ASS_Renderer *renderer;
        library = ass_library_init();
        if (library) {
          renderer = ass_renderer_init(library);
          if (renderer) {
            ass_renderer_done(renderer);
            ass_library_done(library);
            return 0;
          }
          else {
            ass_library_done(library);
            return 1;
          }
        }
        else {
          return 1;
        }
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-lass", "-o", "test"
    system "./test"
  end
end
