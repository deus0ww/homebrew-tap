class Aom < Formula
  desc "Codec library for encoding and decoding AV1 video streams"
  homepage "https://aomedia.googlesource.com/aom"
  url "https://aomedia.googlesource.com/aom.git",
      tag:      "v3.9.0",
      revision: "6cab58c3925e0f4138e15a4ed510161ea83b6db1"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "deus0ww/tap/jpeg-xl"
  depends_on "libvmaf" => :optional

  on_intel do
    depends_on "yasm" => :build
  end

  def install
    ENV.runtime_cpu_detection

    args = [
      "-DCMAKE_INSTALL_RPATH=#{rpath}",
      "-DENABLE_DOCS=off",
      "-DENABLE_EXAMPLES=on",
      "-DENABLE_TESTDATA=off",
      "-DENABLE_TESTS=off",
      "-DENABLE_TOOLS=off",
      "-DBUILD_SHARED_LIBS=on",
    ]
    args << "-DCONFIG_TUNE_VMAF=1" if build.with? "libvmaf"

    ENV.append "CFLAGS", (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast -flto=thin"
    system "cmake", "-S", ".", "-B", "brewbuild", *std_cmake_args, *args
    system "cmake", "--build", "brewbuild"
    system "cmake", "--install", "brewbuild"
  end

  test do
    resource "homebrew-bus_qcif_15fps.y4m" do
      url "https://media.xiph.org/video/derf/y4m/bus_qcif_15fps.y4m"
      sha256 "868fc3446d37d0c6959a48b68906486bd64788b2e795f0e29613cbb1fa73480e"
    end

    testpath.install resource("homebrew-bus_qcif_15fps.y4m")

    system bin/"aomenc", "--webm",
                            "--tile-columns=2",
                            "--tile-rows=2",
                            "--cpu-used=8",
                            "--output=bus_qcif_15fps.webm",
                            "bus_qcif_15fps.y4m"

    system bin/"aomdec", "--output=bus_qcif_15fps_decode.y4m",
                            "bus_qcif_15fps.webm"
  end
end
