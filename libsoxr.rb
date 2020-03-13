class Libsoxr < Formula
  desc "High quality, one-dimensional sample-rate conversion library"
  homepage "https://sourceforge.net/projects/soxr/"
  url "https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz"
  sha256 "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889"

  depends_on "cmake" => :build

  def install
    ENV.append "CFLAGS",      "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CPPFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "CXXFLAGS",    "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCFLAGS",   "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "OBJCXXFLAGS", "-Ofast -flto=thin -march=native -mtune=native"
    ENV.append "LDFLAGS",     "-Ofast -flto=thin -march=native -mtune=native -dead_strip"

    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <soxr.h>

      int main()
      {
        char const *version = 0;
        version = soxr_version();
        if (version == 0)
        {
          return 1;
        }
        return 0;
      }
    EOS
    system ENV.cc, "-L#{lib}", "-lsoxr", "test.c", "-o", "test"
    system "./test"
  end
end
