class JpegXl < Formula
  desc "New file format for still image compression"
  homepage "https://jpeg.org/jpegxl/index.html"
  url "https://github.com/libjxl/libjxl/archive/v0.6.1.tar.gz"
  sha256 "ccbd5a729d730152303be399f033b905e608309d5802d77a61a95faa092592c5"
  license "BSD-3-Clause"
  head "https://github.com/libjxl/libjxl.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "giflib"
  depends_on "imath"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "openexr"
  depends_on "webp"

  uses_from_macos "libxml2" => :build
  uses_from_macos "libxslt" => :build # for xsltproc

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5"
  fails_with gcc: "6"

  # These resources are versioned according to the script supplied with jpeg-xl to download the dependencies:
  # https://github.com/libjxl/libjxl/tree/v#{version}/third_party
  resource "highway" do
    url "https://github.com/google/highway.git",
        revision: "9c775721c1531fd1cf11cf52bbfde4d076691628"
  end

  resource "libpng" do
    url "https://github.com/glennrp/libpng.git",
        revision: "403422674d246921354b61a40041f84dadad830d"
  end

  resource "sjpeg" do
    url "https://github.com/webmproject/sjpeg.git",
        revision: "e255c464b33e2d2dba6beefe7924a366601798b7"
  end

  resource "skcms" do
    url "https://skia.googlesource.com/skcms.git",
        revision: "c2639b59758f405a37877e228ef0716551dfb3db"
  end

  def install
    opts  = Hardware::CPU.arm? ? "-mcpu=native " : "-march=native -mtune=native "
    opts += "-Ofast "
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts

    resources.each { |r| r.stage buildpath/"third_party"/r.download_name }
    mkdir "build" do
      # disable manpages due to problems with asciidoc 10
      system "cmake", "..", "-DBUILD_TESTING=OFF",
        "-DJPEGXL_FORCE_SYSTEM_BROTLI=ON",
        "-DJPEGXL_ENABLE_JNI=OFF",
        "-DJPEGXL_VERSION=#{version}",
        "-DJPEGXL_ENABLE_MANPAGES=OFF",
        *std_cmake_args
      system "cmake", "--build", "."
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  test do
    system "#{bin}/cjxl", test_fixtures("test.jpg"), "test.jxl"
    assert_predicate testpath/"test.jxl", :exist?
  end
end
