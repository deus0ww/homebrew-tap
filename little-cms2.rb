class LittleCms2 < Formula
  desc "Color management engine supporting ICC profiles"
  homepage "http://www.littlecms.com/"
  # Ensure release is announced on http://www.littlecms.com/download.html
  url "https://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.tar.gz"
  sha256 "48c6fdf98396fa245ed86e622028caf49b96fa22f3e5734f853f806fbc8e7d20"
  version_scheme 1
  head "https://github.com/deus0ww/Little-CMS.git"

  depends_on "jpeg"
  depends_on "libtiff"

  def install
    opts = "-Ofast -march=native -mtune=native -flto=thin -funroll-loops -fomit-frame-pointer -ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables"
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    args = %W[--disable-dependency-tracking --prefix=#{prefix}]

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/jpgicc", test_fixtures("test.jpg"), "out.jpg"
    assert_predicate testpath/"out.jpg", :exist?
  end
end
