class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  license :cannot_represent

  if MacOS.version >= :big_sur
    url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
    sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
    head do
      url "https://github.com/mpv-player/mpv.git", branch: "master"
      resource "0001-vo-gpu-next-videotoolbox.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0001-vo-gpu-next-videotoolbox.patch"
        sha256 "549cbf6383e5a1b9884666ffc53f98e2d84eedf501ccc82941cc5f761f5946b6"
      end
      resource "0002-ao-coreaudio-fix-idle.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0002-ao-coreaudio-fix-idle.patch"
        sha256 "fd97ad5c95cd68354ac3348fe7ce825620ada70534f13989568080798dcce27a"
      end
      resource "0003-osdep-macos-fix-display-name.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0003-osdep-macos-fix-display-name.patch"
        sha256 "399174c17380c5fb8a7ec80f7699d1390cdd28a79fae91b49a05bf11331099ae"
      end
    end
  else
    # Last Official Version for macOS < 10.15
    url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
    sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
    head do
      if MacOS.version == :mojave
        url "https://github.com/mpv-player/mpv.git", branch: "master"
      else
        # Last buildable commit on macOS 10.13
        url "https://github.com/mpv-player/mpv/archive/7480efa62c0a2a1779b4fdaa804a6512aa488400.tar.gz"
        sha256 "28c456b51f43509d65b0bcf433bc56a7ad3f6d5f99c28ffc9bf8f660e1c6dd1f"
        patch do  # Set required libplacebo version to v.6.292.1
          url "https://github.com/deus0ww/homebrew-tap/raw/master/mpv-02.patch"
          sha256 "067efc9798cf69b9176250ce95506540c54760050f06846bd4d9c97855e26ce0"
        end
        patch do  # Change version string
          url "https://github.com/deus0ww/homebrew-tap/raw/master/mpv-03.patch"
          sha256 "e997c86fec6d07b6d184eecf647f793a9bfca5a9e015d3d195988caac4302f84"
        end
      end
      patch do  # Fix an issue with old Swift
        url "https://github.com/deus0ww/homebrew-tap/raw/master/mpv-01.patch"
        sha256 "5d0647dd8c167ec5ea49fcc296ce58abead4a5234213b62993d88d50500dd6c7"
      end
      resource "0001-vo-gpu-next-videotoolbox.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0001-vo-gpu-next-videotoolbox.patch"
        sha256 "549cbf6383e5a1b9884666ffc53f98e2d84eedf501ccc82941cc5f761f5946b6"
      end
      resource "0002-ao-coreaudio-fix-idle.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0002-ao-coreaudio-fix-idle.patch"
        sha256 "fd97ad5c95cd68354ac3348fe7ce825620ada70534f13989568080798dcce27a"
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
  depends_on "molten-vk" if MacOS.version >= :big_sur
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "zimg"

  depends_on "libbluray" => :optional
  depends_on "rubberband" => :optional
  depends_on "sdl2" => :optional
  depends_on "vapoursynth" => :optional

  on_macos do
    depends_on "coreutils" => :recommended
    depends_on "deus0ww/tap/dockutil@2" => :recommended if MacOS.version <  :big_sur
    depends_on "deus0ww/tap/dockutil@3" => :recommended if MacOS.version >= :big_sur
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

    resources.each do |r|
      r.stage(buildpath)
      system "git", "apply", r.name
    end

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

    bash_completion.install "etc/mpv.bash-completion" => "mpv"
    zsh_completion.install "etc/_mpv.zsh" => "_mpv"

    # Build, Fix, and Codesign App Bundle
    system "python3.12", "TOOLS/osxbundle.py", "build/mpv", "--skip-deps"
    bindir = "build/mpv.app/Contents/MacOS/"
    rm   bindir + "mpv-bundle"
    mv   bindir + "mpv", bindir + "mpv-bundle"
    ln_s "mpv-bundle", bindir + "mpv"
    system "codesign", "--deep", "-fs", "-", "build/mpv.app"
    prefix.install "build/mpv.app"

    # Add to Dock
    if build.with?("dockutil@2") || build.with?("dockutil@3")
      system "dockutil", "--add", "#{prefix}/mpv.app", "--replacing", "mpv", "--allhomes"
    end
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")

    # Make sure `pkg-config` can parse `mpv.pc` after the `inreplace`.
    system "pkg-config", "mpv"
  end
end
