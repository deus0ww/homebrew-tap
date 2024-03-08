class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  license :cannot_represent

  if MacOS.version > :mojave
    url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.37.0.tar.gz"
    sha256 "1d2d4adbaf048a2fa6ee134575032c4b2dad9a7efafd5b3e69b88db935afaddf"
    head "https://github.com/mpv-player/mpv.git", branch: "master"
  elsif MacOS.version == :mojave # With incompatible commits reverted
    url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.37.0.tar.gz"
    sha256 "1d2d4adbaf048a2fa6ee134575032c4b2dad9a7efafd5b3e69b88db935afaddf"
    head do # Last buildable commit on macOS 10.14 - v.0.37.0-489-gbbbd6e272c
      url "https://github.com/mpv-player/mpv/archive/bbbd6e272ce9bc7b87cff117d270728602df40b5.tar.gz"
      sha256 "9ad63ace7bebcf85b33bbd94baf8e779f6ce4f918971b0b540afa55d0eb7a18a"
    end
    patch do # Revert DisplayName change
      url "https://github.com/deus0ww/homebrew-tap/raw/master/patches/mpv-10.14.patch"
      sha256 "1545c6785a9d24f9365439cc8620011985c30a24d03550dd9c1ca1829894eb16"
    end
  else # Last Official Version for macOS < 10.15
    url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
    sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
    head do # Last buildable commit on macOS 10.13 - v.0.36.0-722-g7480efa62c with libplacebo v.6.318
      url "https://github.com/mpv-player/mpv/archive/7480efa62c0a2a1779b4fdaa804a6512aa488400.tar.gz"
      sha256 "28c456b51f43509d65b0bcf433bc56a7ad3f6d5f99c28ffc9bf8f660e1c6dd1f"
      patch do # Fix old Swift + Downgrade libplacebo
        url "https://github.com/deus0ww/homebrew-tap/raw/master/patches/mpv-10.13.patch"
        sha256 "5f6b77411242fd4798efc140aeb5045eec026e5546828358c2269304a193e955"
      end
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "python@3.12" => :build
  depends_on xcode: :build

  depends_on "deus0ww/tap/ffmpeg"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/libplacebo"
  depends_on "deus0ww/tap/yt-dlp"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libdvdnav"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "zimg"

  depends_on "libbluray" => :optional
  depends_on "rubberband" => :optional
  depends_on "sdl2" => :optional
  depends_on "vapoursynth" => :optional

  on_macos do
    depends_on "coreutils" => :recommended
    depends_on "deus0ww/tap/dockutil" => :recommended
    depends_on "tag" => :recommended
    depends_on "trash" => :recommended
  end

  on_linux do
    depends_on "alsa-lib"
  end

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["LANG"]   = "en_US.UTF-8"

    # force meson find ninja from homebrew
    ENV["NINJA"] = Formula["ninja"].opt_bin/"ninja"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"

    args = %W[
      -Db_lto=true
      -Db_lto_mode=thin

      -Dlibmpv=true
      -Ddvdnav=enabled

      --default-library=both
      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
      --mandir=#{man}
    ]
    args << ("-Dc_args=" + (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast")
    args << "-Dswift-flags=-O -wmo"

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    if OS.mac?
      # `pkg-config --libs mpv` includes libarchive, but that package is
      # keg-only so it needs to look for the pkgconfig file in libarchive's opt
      # path.
      libarchive = Formula["libarchive"].opt_prefix
      inreplace lib/"pkgconfig/mpv.pc" do |s|
        s.gsub!(/^Requires\.private:(.*)\blibarchive\b(.*?)(,.*)?$/,
                "Requires.private:\\1#{libarchive}/lib/pkgconfig/libarchive.pc\\3")
      end
    end

    if MacOS.version > :mojave
      bash_completion.install "etc/mpv.bash-completion" => "mpv"
      zsh_completion.install "etc/_mpv.zsh" => "_mpv"
    end

    # Build, Fix, and Codesign App Bundle
    system "python3.12", "TOOLS/osxbundle.py", "build/mpv", "--skip-deps"
    if MacOS.version < :mojave
      bindir = "build/mpv.app/Contents/MacOS/"
      rm_f bindir + "mpv-bundle"
      cp   bindir + "mpv", bindir + "mpv-bundle"
      system "codesign", "--deep", "-fs", "-", "build/mpv.app"
    end
    prefix.install "build/mpv.app"

    # Add to Dock
    system "dockutil", "--add", "#{prefix}/mpv.app", "--replacing", "mpv", "--allhomes" if build.with? "dockutil"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")

    # Make sure `pkg-config` can parse `mpv.pc` after the `inreplace`.
    system "pkg-config", "mpv"
  end
end
