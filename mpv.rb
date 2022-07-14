class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.34.1.tar.gz"
  sha256 "32ded8c13b6398310fa27767378193dc1db6d78b006b70dbcbd3123a1445e746"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on xcode: :build

  depends_on "deus0ww/tap/ffmpeg"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/yt-dlp"
  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "little-cms2"
  depends_on "luajit-openresty"
  depends_on "mujs"
  depends_on "rubberband"
  depends_on "uchardet"
  depends_on "vapoursynth"
  depends_on "zimg"

  depends_on "subliminal" => :recommended

  depends_on "jack" => :optional
  depends_on "libaacs" => :optional
  depends_on "libbluray" => :optional
  depends_on "libcaca" => :optional
  depends_on "libcdio" => :optional
  depends_on "libdvdnav" => :optional
  depends_on "libdvdread" => :optional
  depends_on "sdl2" => :optional

  on_macos do
    depends_on "deus0ww/tap/dockutil@2" => :recommended if MacOS.version <  :big_sur
    depends_on "deus0ww/tap/dockutil@3" => :recommended if MacOS.version >= :big_sur
    depends_on "coreutils" => :recommended
    depends_on "tag" => :recommended
    depends_on "trash" => :recommended
  end

  def install
    opts  = Hardware::CPU.arm? ? "-mcpu=native " : "-march=native -mtune=native "
    opts += "-Ofast -flto=thin -funroll-loops -fomit-frame-pointer "
    opts += "-ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables "
    opts += "-fforce-emit-vtables " if MacOS.version >= :mojave
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["LANG"]   = "en_US.UTF-8"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"
    # luajit-openresty is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["luajit-openresty"].opt_lib/"pkgconfig"

    args = %W[
      --prefix=#{prefix}
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --docdir=#{doc}
      --mandir=#{man}
      --zshdir=#{zsh_completion}

      --disable-html-build
      --enable-libmpv-shared
    ]
    args << "--swift-flags=-O -wmo"

    inreplace "TOOLS/dylib-unhell.py", "libraries(lib, result)", "lib = lib.replace(\"@loader_path\", \"" + "#{HOMEBREW_PREFIX}/lib" + "\"); libraries(lib, result)"

    system Formula["python@3.10"].opt_bin/"python3", "bootstrap.py"
    system Formula["python@3.10"].opt_bin/"python3", "waf", "configure", *args
    system Formula["python@3.10"].opt_bin/"python3", "waf", "install"
    system Formula["python@3.10"].opt_bin/"python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")
  end
end
