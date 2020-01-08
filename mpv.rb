class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.31.0.tar.gz"
  sha256 "805a3ac8cf51bfdea6087a6480c18835101da0355c8e469b6d488a1e290585a5"
  head "https://github.com/mpv-player/mpv.git"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build

  depends_on "deus0ww/tap/ffmpeg"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/little-cms2"
  depends_on "deus0ww/tap/luajit"
  depends_on "deus0ww/tap/vapoursynth"

  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "mujs"
  depends_on "rubberband"
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
  # depends_on "zimg" => :optional

  def install
    ENV.append "CXXFLAGS", "-Ofast -flto -march=native -mtune=native"
    ENV.append "CFLAGS",   "-Ofast -flto -march=native -mtune=native"
    ENV.append "LDFLAGS",  "-Ofast -flto -march=native -mtune=native"

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

      --disable-zimg
      --enable-html-build
      --enable-libmpv-shared
    ]
    args << "--swift-flags=-O -wmo -Xcc -Ofast -Xcc -flto -Xcc -march=native -Xcc -mtune=native"

    args << "--enable-dvdnav" if build.with? "libdvdnav"
    args << "--enable-cdda"   if build.with? "libcdio"
    args << "--enable-sdl2"   if build.with? "sdl2"

    system "python3", "bootstrap.py"
    system "python3", "waf", "configure", *args
    system "python3", "waf", "install"

    system "python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
  end
end
