class Harfbuzz < Formula
  desc "OpenType text shaping engine"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/harfbuzz/harfbuzz/archive/2.7.0.tar.gz"
  sha256 "4dba05de1fd44705f54c40d801e0e3d4833555d004cb611cc18675173feae75b"
  license "MIT"
  head "https://github.com/harfbuzz/harfbuzz.git"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cairo"
  depends_on "freetype"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "graphite2"
  depends_on "icu4c"

  resource "ttf" do
    url "https://github.com/harfbuzz/harfbuzz/raw/fc0daafab0336b847ac14682e581a8838f36a0bf/test/shaping/fonts/sha1sum/270b89df543a7e48e206a2d830c0e10e5265c630.ttf"
    sha256 "9535d35dab9e002963eef56757c46881f6b3d3b27db24eefcc80929781856c77"
  end

  # Fix linking issues on High Sierra
  # https://github.com/harfbuzz/harfbuzz/pull/2605
  # Remove in next release
  patch do
    url "https://github.com/harfbuzz/harfbuzz/commit/7c61caa7384e9c3afa0d9237bf6cd303eb5ef3a1.patch?full_index=1"
    sha256 "4d60b681918c2b911da9a84e37386ed1fa48794d5c943ff9a7bd50eb3a255969"
  end

  def install
    opts = "-Ofast -march=native -mtune=native -flto=thin -funroll-loops -fomit-frame-pointer -ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables"
    opts += " -fforce-emit-vtables" if MacOS.version >= :mojave
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"
    args = %w[
      --default-library=both
      -Dcairo=enabled
      -Dcoretext=enabled
      -Dfreetype=enabled
      -Dglib=enabled
      -Dgobject=enabled
      -Dgraphite=enabled
      -Dicu=enabled
      -Dintrospection=enabled
    ]

    mkdir "build" do
      system "meson", *std_meson_args, *args, ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    resource("ttf").stage do
      shape = `echo 'സ്റ്റ്' | #{bin}/hb-shape 270b89df543a7e48e206a2d830c0e10e5265c630.ttf`.chomp
      assert_equal "[glyph201=0+1183|U0D4D=0+0]", shape
    end
  end
end
