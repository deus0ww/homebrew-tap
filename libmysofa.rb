class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/v0.8.tar.gz"
  sha256 "0e0abb6ec6f5f09266325741d6ef218532187129f65d0bc6b21e155760dfb2ad"
  head "https://github.com/hoene/libmysofa.git"

  depends_on "cmake" => :build

  depends_on "cunit"

  def install
    ENV.O3
    ENV.append "CXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS", "-Ofast -flto=thin"

    cd "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Release"
      system "make", "all"
      system "make", "install"
    end
  end
end
