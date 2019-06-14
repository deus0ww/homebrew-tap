class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/v0.7.tar.gz"
  sha256 "c1e6a0a91fee89625a60befec674bf2b4bf17055676933727f106785e0ea42a3"
  head "https://github.com/hoene/libmysofa.git"

  depends_on "cmake" => :build

  depends_on "cunit"

  def install
    cd "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Debug"
      system "make", "all"
      system "make", "install"
    end
  end
end
