class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-7.0.1.tar.xz"
  sha256 "bce9eeb0f17ef8982390b1f37711a61b4290dc8c2a0c1a37b5857e85bfb0e4ff"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  license "GPL-2.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  livecheck do
    url "https://ffmpeg.org/download.html"
    regex(/href=.*?ffmpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  if MacOS.version > :mojave
    depends_on "librist"   # Build issue with gnutls on macOS 10.14
    depends_on "libvmaf"   # Avoiding building Rust
    depends_on "openjpeg"  # Avoiding building doxygen
    depends_on "openvino"  # Build issue with gnutls on macOS 10.14
    depends_on "rav1e"     # Avoiding building Rust
    depends_on "snappy"    # Build issue on macOS 10.13
    depends_on "tesseract" # Build issue on macOS <10.15
    depends_on "zeromq"    # Avoiding building Boost
    depends_on "aom"       # Without libvmaf
    depends_on "jpeg-xl"   # Without docs
  else
    depends_on "deus0ww/tap/aom"
    depends_on "deus0ww/tap/jpeg-xl"
    depends_on "deus0ww/tap/openjpeg"
  end

  depends_on "make" => :build
  depends_on "pkg-config" => :build

  depends_on "aribb24"
  depends_on "bzip2"       # uses_from_macos
  depends_on "dav1d"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/libmysofa"
  depends_on "deus0ww/tap/libplacebo"
  depends_on "fdk-aac"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "harfbuzz"
  depends_on "lame"
  depends_on "libbluray"
  depends_on "libbs2b"
  depends_on "libsoxr"
  depends_on "libvidstab"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxml2"     # uses_from_macos
  depends_on "opencore-amr"
  depends_on "openssl@3"
  depends_on "opus"
  depends_on "rubberband"
  depends_on "sdl2"
  depends_on "speex"
  depends_on "srt"
  depends_on "svt-av1"
  depends_on "theora"
  depends_on "webp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"
  depends_on "zimg"
  depends_on "zlib"        # uses_from_macos

  depends_on "game-music-emu" => :optional
  depends_on "libcaca" => :optional
  depends_on "libgsm" => :optional
  depends_on "libmodplug" => :optional
  depends_on "libopenmpt" => :optional
  depends_on "librsvg" => :optional
  depends_on "libssh" => :optional
  depends_on "openh264" => :optional
  depends_on "rtmpdump" => :optional
  depends_on "two-lame" => :optional

  on_macos do
    depends_on "libarchive"
    depends_on "libogg"
    depends_on "libsamplerate"
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxext"
    depends_on "libxv"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  fails_with gcc: "5"

  # Fix for QtWebEngine, do not remove
  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=270209
  patch do
    url "https://gitlab.archlinux.org/archlinux/packaging/packages/ffmpeg/-/raw/5670ccd86d3b816f49ebc18cab878125eca2f81f/add-av_stream_get_first_dts-for-chromium.patch"
    sha256 "57e26caced5a1382cb639235f9555fc50e45e7bf8333f7c9ae3d49b3241d3f77"
  end

  # Yt-dlp Patches
  patch do
    url "https://github.com/yt-dlp/FFmpeg-Builds/raw/master/patches/ffmpeg/master/0001-Nonstandard-HEVC-over-FLV.patch"
    sha256 "1e1f977ca95968e1e6f50a36865b82ab505fb0190765d856e520604107644ca6"
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    args = %W[
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --prefix=#{prefix}

      --enable-gpl
      --enable-nonfree
      --enable-pthreads
      --enable-shared
      --enable-version3

      --enable-frei0r
      --enable-libaom
      --enable-libaribb24
      --enable-libass
      --enable-libbluray
      --enable-libbs2b
      --enable-libdav1d
      --enable-libfdk-aac
      --enable-libfontconfig
      --enable-libfreetype
      --enable-libharfbuzz
      --enable-libjxl
      --enable-libmp3lame
      --enable-libmysofa
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-libopenjpeg
      --enable-libopus
      --enable-libplacebo
      --enable-librubberband
      --enable-libsoxr
      --enable-libspeex
      --enable-libsrt
      --enable-libsvtav1
      --enable-libtheora
      --enable-libvidstab
      --enable-libvorbis
      --enable-libvpx
      --enable-libwebp
      --enable-libx264
      --enable-libx265
      --enable-libxml2
      --enable-libxvid
      --enable-libzimg
      --enable-lzma
      --enable-openssl

      --disable-htmlpages
      --disable-podpages
      --disable-txtpages

      --disable-libjack
      --disable-indev=jack
    ]

    # Needs corefoundation, coremedia, corevideo
    args += %w[--enable-opencl --enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    args << "--enable-libopenvino"  if build.with? "openvino"
    args << "--enable-librav1e"     if build.with? "rav1e"
    args << "--enable-libsnappy"    if build.with? "snappy"
    args << "--enable-libtesseract" if build.with? "tesseract"
    args << "--enable-librist"      if build.with? "librist"
    args << "--enable-libvmaf"      if build.with? "libvmaf"
    args << "--enable-libzmq"       if build.with? "zeromq"

    args << "--enable-libcaca"      if build.with? "libcaca"
    args << "--enable-libgme"       if build.with? "game-music-emu"
    args << "--enable-libgsm"       if build.with? "libgsm"
    args << "--enable-libmodplug"   if build.with? "libmodplug"
    args << "--enable-libopenh264"  if build.with? "openh264"
    args << "--enable-libopenmpt"   if build.with? "libopenmpt"
    args << "--enable-librsvg"      if build.with? "librsvg"
    args << "--enable-librtmp"      if build.with? "rtmpdump"
    args << "--enable-libssh"       if build.with? "libssh"
    args << "--enable-libtwolame"   if build.with? "two-lame"

    opts  = Hardware::CPU.arm? ? "-mcpu=native " : "-march=native -mtune=native "
    args << ("--extra-cflags="    + opts)
    args << ("--extra-cxxflags="  + opts)
    args << ("--extra-objcflags=" + opts)
    args << ("--extra-ldflags="   + opts)
    # args << "--enable-hardcoded-tables"
    args << "--enable-lto"
    args << "--optflags=-Ofast"

    system "./configure", *args
    system "gmake", "install"

    # Build and install additional FFmpeg tools
    system "gmake", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
