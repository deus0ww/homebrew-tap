class Libsoxr < Formula
  desc "High quality, one-dimensional sample-rate conversion library"
  homepage "https://sourceforge.net/projects/soxr/"
  url "https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz"
  sha256 "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889"

  depends_on "cmake" => :build

  def install
    ENV.O3
    ENV.append "CXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS", "-Ofast -flto=thin"

    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
