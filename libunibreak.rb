class Libunibreak < Formula
  desc "Unicode line and word breaking algorithms"
  homepage "https://github.com/adah1972/libunibreak"
  url "https://github.com/adah1972/libunibreak/releases/download/libunibreak_5_0/libunibreak-5.0.tar.gz"
  sha256 "58f2fe4f9d9fc8277eb324075ba603479fa847a99a4b134ccb305ca42adf7158"
  license "Zlib"
  head "https://github.com/adah1972/libunibreak.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "wget" => :build

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "linebreakdata"
    system "make", "wordbreakdata"
    system "make", "graphemebreakdata"
    system "make", "emojidata"
    system "make", "install"
  end
end
