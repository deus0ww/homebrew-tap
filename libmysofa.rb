class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/v0.9.1.tar.gz"
  sha256 "b942cc4a6b5da6187d38574f7653489347ceadf7c1ab7168dfe5e307e999dcc6"
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
