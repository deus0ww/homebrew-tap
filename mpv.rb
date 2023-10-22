class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
  sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
  license :cannot_represent

  head do
    url "https://github.com/mpv-player/mpv.git", branch: "master"

    # https://github.com/mpv-player/mpv/issues/12653
    patch :DATA if MacOS.version < :big_sur

    resource "0001-vo-gpu-next-videotoolbox.patch" do
      url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0001-vo-gpu-next-videotoolbox.patch"
      sha256 "4be3036bf4b03222f48f2c15399439e00d9d55f8051bef6d077be8c8f6463b32"
    end

    resource "0002-ao-coreaudio-fix-idle.patch" do
      url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0002-ao-coreaudio-fix-idle.patch"
      sha256 "fd97ad5c95cd68354ac3348fe7ce825620ada70534f13989568080798dcce27a"
    end

    if MacOS.version >= :big_sur
      resource "0003-osdep-macos-fix-display-name.patch" do
        url "https://github.com/m154k1/mpv-build-macOS/raw/master/patches/mpv/0003-osdep-macos-fix-display-name.patch"
        sha256 "399174c17380c5fb8a7ec80f7699d1390cdd28a79fae91b49a05bf11331099ae"
      end
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "python@3.11" => :build
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
    args << "-Dsdl2=enabled" if build.with? "sdl2"

    args << ("-Dc_args=" + (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast")
    args << "-Dswift-flags=-O -wmo"

    resources.each do |r|
      r.stage(buildpath)
      system "git",  "apply", r.name
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
    system "python3.11", "TOOLS/osxbundle.py", "build/mpv", "--skip-deps"
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
__END__
diff --git a/video/out/mac_common.swift b/video/out/mac_common.swift
index 12d2870add..fd3e2c0018 100644
--- a/video/out/mac_common.swift
+++ b/video/out/mac_common.swift
@@ -111,11 +111,11 @@ class MacCommon: Common {
                                          _ flagsOut: UnsafeMutablePointer<CVOptionFlags>) -> CVReturn
     {
         let frameTimer = mpv?.macOpts.macos_render_timer ?? Int32(RENDER_TIMER_CALLBACK)
-        let signalSwap = { [self] in
-            swapLock.lock()
-            swapTime += 1
-            swapLock.signal()
-            swapLock.unlock()
+        let signalSwap = {
+            self.swapLock.lock()
+            self.swapTime += 1
+            self.swapLock.signal()
+            self.swapLock.unlock()
         }
 
         if frameTimer != RENDER_TIMER_SYSTEM {

