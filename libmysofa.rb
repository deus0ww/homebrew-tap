class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76"
  license "BSD-3-Clause"
  head "https://github.com/hoene/libmysofa.git", branch: "master"

  depends_on "cmake" => :build

  depends_on "cunit"

  def install
    ENV.append "CFLAGS", (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast -flto=thin"

    cd "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Release"
      system "make", "all"
      system "make", "install"
    end
  end
end
