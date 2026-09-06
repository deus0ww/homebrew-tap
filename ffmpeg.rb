class Ffmpeg < Formula
  desc "Play, record, convert, and stream many audio and video codecs"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-9.0.1.tar.xz"
  sha256 "cf38e0e28c7e5605942c4a77755349b0145804a397af37eb1fb4c77cb237f635"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  # Passing `--enable-version3` changes the license to GPL v3+.
  license "GPL-3.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  livecheck do
    url "https://ffmpeg.org/download.html"
    regex(/href=.*?ffmpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on "aribb24"
  depends_on "bzip2"       # uses_from_macos
  depends_on "dav1d"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/libmysofa"
  depends_on "deus0ww/tap/libplacebo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r" => :no_linkage
  depends_on "ggml"
  depends_on "harfbuzz"
  depends_on "jpeg-xl"
  depends_on "lame"
  depends_on "libbluray"
  depends_on "libbs2b"
  depends_on "librist"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvidstab"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxml2"     # uses_from_macos
  depends_on "opencore-amr"
  depends_on "openjpeg"
  depends_on "openssl@3"
  depends_on "opus"
  depends_on "rav1e"
  depends_on "rubberband"
  depends_on "sdl2-compat"
  depends_on "snappy"
  depends_on "speex"
  depends_on "srt"
  depends_on "svt-av1"
  depends_on "tesseract"
  depends_on "theora"
  depends_on "webp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"
  depends_on "zeromq"
  depends_on "zimg"
  depends_on "zlib"        # uses_from_macos

  on_macos do
    depends_on "libarchive"
    depends_on "libogg"
    depends_on "libsamplerate"
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxext"
    depends_on "libxv"
    depends_on "zlib-ng-compat"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.ld64_version.between?("1015.7", "1022.1")

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}

      --enable-gpl
      --enable-nonfree
      --enable-pthreads
      --enable-shared
      --enable-version3

      --disable-htmlpages
      --disable-podpages
      --disable-txtpages

      --enable-frei0r
      --enable-libaom
      --enable-libaribb24
      --enable-libass
      --enable-libbluray
      --enable-libbs2b
      --enable-libdav1d
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
      --enable-librav1e
      --enable-librist
      --enable-librubberband
      --enable-libsnappy
      --enable-libsoxr
      --enable-libspeex
      --enable-libsrt
      --enable-libssh
      --enable-libsvtav1
      --enable-libtesseract
      --enable-libtheora
      --enable-libvidstab
      --enable-libvmaf
      --enable-libvorbis
      --enable-libvpx
      --enable-libwebp
      --enable-libx264
      --enable-libx265
      --enable-libxml2
      --enable-libxvid
      --enable-libzimg
      --enable-libzmq
      --enable-lzma
      --enable-openssl

      --disable-libjack
      --disable-indev=jack
    ]

    # Needs corefoundation, coremedia, corevideo
    args += %w[--enable-opencl --enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    opts  = Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native"
    args << ("--extra-cflags="    + opts)
    args << ("--extra-cxxflags="  + opts)
    args << ("--extra-objcflags=" + opts)
    opts += " -Xlinker -no_fixup_chains" unless Hardware::CPU.arm?
    args << ("--extra-ldflags="   + opts)
    # args << "--enable-hardcoded-tables"
    args << "--enable-lto"
    args << "--optflags=-Ofast"

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  def caveats
    <<~EOS
      ffmpeg-full includes additional tools and libraries that are not included in the regular ffmpeg formula.
    EOS
  end

  test do
    # Create a 5 second test MP4
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=5", mp4out
    assert_match(/Duration: 00:00:05\.00,.*Video: h264/m, shell_output("#{bin}/ffprobe -hide_banner #{mp4out} 2>&1"))

    # Re-encode it in HEVC/Matroska
    mkvout = testpath/"video.mkv"
    system bin/"ffmpeg", "-i", mp4out, "-c:v", "hevc", mkvout
    assert_match(/Duration: 00:00:05\.00,.*Video: hevc/m, shell_output("#{bin}/ffprobe -hide_banner #{mkvout} 2>&1"))
  end
end
