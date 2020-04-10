class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.32.0.tar.gz"
  sha256 "9163f64832226d22e24bbc4874ebd6ac02372cd717bef15c28a0aa858c5fe592"
  head "https://github.com/mpv-player/mpv.git" # , :branch => 'name'

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on :xcode => :build

  depends_on "deus0ww/tap/ffmpeg"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/little-cms2"
  depends_on "deus0ww/tap/luajit"
  depends_on "deus0ww/tap/rubberband"
  depends_on "deus0ww/tap/vapoursynth"
  depends_on "deus0ww/tap/zimg"

  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "youtube-dl"

  depends_on "jack" => :optional
  depends_on "libaacs" => :optional
  depends_on "libbluray" => :optional
  depends_on "libcaca" => :optional
  depends_on "libcdio" => :optional
  depends_on "libdvdnav" => :optional
  depends_on "libdvdread" => :optional
  depends_on "sdl2" => :optional

  def install
    ENV.append "CFLAGS",      "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CPPFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CXXFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCFLAGS",   "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCXXFLAGS", "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "LDFLAGS",     "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections -dead_strip"

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["LANG"]   = "en_US.UTF-8"
    ENV["TOOLCHAINS"] = "swift"

    args = %W[
      --prefix=#{prefix}
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --docdir=#{doc}
      --mandir=#{man}
      --zshdir=#{zsh_completion}

      --enable-html-build
      --enable-libmpv-shared
    ]
    args << "--swift-flags=-O -wmo -Xcc -Ofast -Xcc -march=native -Xcc -mtune=native -Xcc -flto=thin -Xcc -fwhole-program-vtables -Xcc -ffunction-sections -Xcc -fdata-sections"

    args << "--enable-dvdnav" if build.with? "libdvdnav"
    args << "--enable-cdda"   if build.with? "libcdio"
    args << "--enable-sdl2"   if build.with? "sdl2"

    system Formula["python@3.8"].opt_bin/"python3", "bootstrap.py"
    system Formula["python@3.8"].opt_bin/"python3", "waf", "configure", *args
    system Formula["python@3.8"].opt_bin/"python3", "waf", "install"
    system Formula["python@3.8"].opt_bin/"python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
  end
end
