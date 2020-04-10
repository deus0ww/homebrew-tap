class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/v1.0.tar.gz"
  sha256 "0b3866cf4c4245124ad6e7e6395f1d9cbcc121cccc6b280ff70052f84d97408d"
  head "https://github.com/hoene/libmysofa.git"

  depends_on "cmake" => :build

  depends_on "cunit"

  def install
    ENV.append "CFLAGS",      "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CPPFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "CXXFLAGS",    "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCFLAGS",   "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "OBJCXXFLAGS", "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections"
    ENV.append "LDFLAGS",     "-Ofast -march=native -mtune=native -flto=thin -fwhole-program-vtables -ffunction-sections -fdata-sections -dead_strip"

    cd "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Release"
      system "make", "all"
      system "make", "install"
    end
  end
end
