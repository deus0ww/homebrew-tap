# frozen_string_literal: true

class Libmysofa < Formula
  desc "Library for reading AES SOFA files"
  homepage "https://github.com/hoene/libmysofa"
  url "https://github.com/hoene/libmysofa/archive/v1.1.tar.gz"
  sha256 "e30846be11499c2282ad85edcab7bcca9bf86502df40c343d1f3ff07db17c765"
  license "BSD-3-Clause"
  head "https://github.com/hoene/libmysofa.git"

  depends_on "cmake" => :build

  depends_on "cunit"

  def install
    opts = "-Ofast -march=native -mtune=native -flto=thin -funroll-loops -fomit-frame-pointer -ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables"
    opts += " -fforce-emit-vtables" if MacOS.version >= :mojave
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    cd "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_BUILD_TYPE=Release"
      system "make", "all"
      system "make", "install"
    end
  end
end
