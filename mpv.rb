class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/6e6ec331685c78584a818f524286670911e8b4af.tar.gz"
  version "0.29.1~6e6ec33"
  sha256 "fbb5ebc72c55af6e62cb3835b87b0fd26160533350f17e73712791870bdbe017"
  head "https://github.com/deus0ww/mpv.git"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build

  depends_on "deus0ww/tap/ffmpeg"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/little-cms2"
  depends_on "deus0ww/tap/luajit"

  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "libbluray"
  depends_on "mujs"
  depends_on "rubberband"
  depends_on "uchardet"
  depends_on "vapoursynth"
  depends_on "youtube-dl"

  depends_on "jack" => :optional
  depends_on "libaacs" => :optional
  depends_on "libcaca" => :optional
  depends_on "libdvdnav" => :optional
  depends_on "libdvdread" => :optional

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"
    ENV.O3

    args = %W[
      --prefix=#{prefix}
      --enable-html-build
      --enable-javascript
      --enable-libmpv-shared

      --enable-lua
      --enable-libarchive
      --enable-libbluray
      --enable-uchardet

      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --mandir=#{man}
      --docdir=#{doc}
      --zshdir=#{zsh_completion}
    ]

    args << "--enable-dvdnav" if build.with? "libdvdnav"
    args << "--enable-dvdread" if build.with? "libdvdread"

    system "./bootstrap.py"
    system "python3", "waf", "configure", *args
    system "python3", "waf", "install"

    system "python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
  end
end
