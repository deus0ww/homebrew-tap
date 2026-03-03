class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/refs/tags/v1.3.4.tar.gz"
  sha256 "64c661f75ef39edf68bfc3a28403d2b5a0bd251d0b9f5d021ed6f7917867fb37"
  license "BSD-3-Clause"
  head "https://github.com/hoene/libmysofa.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "zlib"

  def install
    ENV.append "CFLAGS", (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast -flto"
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, "-D BUILD_TESTS=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mysofa.h>

      int main(void)
      {
        char buffer[9] = "TESTDATA";
        int filter_length;
        int err;
        struct MYSOFA_EASY *hrtf = NULL;
        hrtf = mysofa_open_data(buffer, 9, 48000, &filter_length, &err);
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lmysofa", "-o", "test"
    system "./test"
  end
end
