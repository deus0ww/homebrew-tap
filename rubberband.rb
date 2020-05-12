class Rubberband < Formula
  desc "Audio time stretcher tool and library"
  homepage "https://breakfastquay.com/rubberband/"
  url "https://breakfastquay.com/files/releases/rubberband-1.8.2.tar.bz2"
  sha256 "86bed06b7115b64441d32ae53634fcc0539a50b9b648ef87443f936782f6c3ca"
  head "https://bitbucket.org/breakfastquay/rubberband/", :using => :hg

  depends_on "pkg-config" => :build
  depends_on "libsamplerate"
  depends_on "libsndfile"

  def install
    opts = "-Ofast -march=native -mtune=native -flto=thin -funroll-loops -fomit-frame-pointer -ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables"
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    inreplace ["Makefile.osx"] do |s|
      s.gsub! "-ffast-math -mfpmath=sse -msse -msse2 -O3 -ftree-vectorize", opts
      s.gsub! "-lpthread", opts + " -lpthread -dead_strip"
      s.gsub! "DUSE_SPEEX", "DHAVE_LIBSAMPLERATE"
      s.gsub! "-framework Accelerate", "-framework Accelerate -L/usr/local/lib -lsamplerate"
    end

    inreplace ["src/StretcherImpl.cpp"] do |s|
      s.gsub! "Resampler::FastestTolerable", "Resampler::Best"
    end

    system "make", "-f", "Makefile.osx"
    # HACK: Manual install because "make install" is broken
    # https://github.com/Homebrew/homebrew-core/issues/28660
    bin.install "bin/rubberband"
    lib.install "lib/librubberband.dylib" => "librubberband.2.1.1.dylib"
    lib.install_symlink lib/"librubberband.2.1.1.dylib" => "librubberband.2.dylib"
    lib.install_symlink lib/"librubberband.2.1.1.dylib" => "librubberband.dylib"
    include.install "rubberband"

    cp "rubberband.pc.in", "rubberband.pc"
    inreplace "rubberband.pc", "%PREFIX%", opt_prefix
    (lib/"pkgconfig").install "rubberband.pc"
  end

  test do
    output = shell_output("#{bin}/rubberband -t2 #{test_fixtures("test.wav")} out.wav 2>&1")
    assert_match "Pass 2: Processing...", output
  end
end
