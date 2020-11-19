# frozen_string_literal: true

class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  license "GPL-2.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git"

  stable do
    url "https://ffmpeg.org/releases/ffmpeg-4.3.1.tar.xz"
    sha256 "ad009240d46e307b4e03a213a0f49c11b650e445b1f8be0dda2a9212b34d2ffb"

    # https://trac.ffmpeg.org/ticket/8760
    # Remove in next release
    patch do
      url "https://github.com/FFmpeg/FFmpeg/commit/7c59e1b0f285cd7c7b35fcd71f49c5fd52cf9315.patch?full_index=1"
      sha256 "1cbe1b68d70eadd49080a6e512a35f3e230de26b6e1b1c859d9119906417737f"
    end
  end

  livecheck do
    url "https://ffmpeg.org/download.html"
    regex(/href=.*?ffmpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  option "with-chromaprint", "Enable the Chromaprint audio fingerprinting library"
  option "with-librsvg", "Enable SVG files as inputs via librsvg"
  option "with-libssh", "Enable SFTP protocol via libssh"
  option "with-openh264", "Enable OpenH264 library"
  option "with-zeromq", "Enable using libzeromq to receive commands sent through a libzeromq client"
  option "with-libvmaf", "Enable libvmaf scoring library"

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build

  depends_on "aom"
  depends_on "deus0ww/tap/dav1d"
  depends_on "deus0ww/tap/libass"
  depends_on "deus0ww/tap/libmysofa"
  depends_on "deus0ww/tap/libsoxr"
  depends_on "deus0ww/tap/openjpeg"
  depends_on "deus0ww/tap/rubberband"
  depends_on "deus0ww/tap/tesseract"
  depends_on "deus0ww/tap/zimg"
  depends_on "fdk-aac"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "lame"
  depends_on "libbluray"
  depends_on "libbs2b"
  depends_on "libvidstab"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "opencore-amr"
  depends_on "openssl@1.1"
  depends_on "opus"
  depends_on "rav1e"
  depends_on "rtmpdump"
  depends_on "sdl2"
  depends_on "snappy"
  depends_on "speex"
  depends_on "srt"
  depends_on "theora"
  depends_on "webp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"

  depends_on "chromaprint" => :optional
  depends_on "game-music-emu" => :optional
  depends_on "libcaca" => :optional
  depends_on "libgsm" => :optional
  depends_on "libmodplug" => :optional
  depends_on "librsvg" => :optional
  depends_on "libssh" => :optional
  depends_on "libvmaf" => :optional
  depends_on "openh264" => :optional
  depends_on "two-lame" => :optional
  depends_on "wavpack" => :optional
  depends_on "zeromq" => :optional

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    args = %W[
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --prefix=#{prefix}

      --enable-avresample
      --enable-ffplay
      --enable-gpl
      --enable-nonfree
      --enable-opencl
      --enable-pthreads
      --enable-shared
      --enable-version3
      --enable-videotoolbox

      --enable-frei0r
      --enable-libaom
      --enable-libass
      --enable-libbluray
      --enable-libbs2b
      --enable-libdav1d
      --enable-libfdk-aac
      --enable-libfontconfig
      --enable-libfreetype
      --enable-libmp3lame
      --enable-libmysofa
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-libopenjpeg
      --enable-libopus
      --enable-librav1e
      --enable-librtmp
      --enable-librubberband
      --enable-libsnappy
      --enable-libsoxr
      --enable-libspeex
      --enable-libsrt
      --enable-libtesseract
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

    args << "--enable-chromaprint" if build.with? "chromaprint"
    args << "--enable-libcaca" if build.with? "libcaca"
    args << "--enable-libgme" if build.with? "game-music-emu"
    args << "--enable-libgsm" if build.with? "libgsm"
    args << "--enable-libmodplug" if build.with? "libmodplug"
    args << "--enable-libopenh264" if build.with? "openh264"
    args << "--enable-librsvg" if build.with? "librsvg"
    args << "--enable-libssh" if build.with? "libssh"
    args << "--enable-libtwolame" if build.with? "two-lame"
    args << "--enable-libvmaf" if build.with? "libvmaf"
    args << "--enable-libwavpack" if build.with? "wavpack"
    args << "--enable-libzmq" if build.with? "zeromq"

    args << "--enable-hardcoded-tables"
    args << "--enable-lto"
    args << "--optflags=-Ofast"

    opts  = "-march=native -mtune=native -funroll-loops -fomit-frame-pointer"
    opts += " -ffunction-sections -fdata-sections -fstrict-vtable-pointers"
    opts += " -fforce-emit-vtables" if MacOS.version >= :mojave
    args << "--extra-cflags="    + opts
    args << "--extra-cxxflags="  + opts + " -fwhole-program-vtables"
    args << "--extra-objcflags=" + opts
    args << "--extra-ldflags="   + opts + " -fwhole-program-vtables"

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }

    # Fix for Non-executables that were installed to bin/
    mv bin/"python", pkgshare/"python", force: true
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
