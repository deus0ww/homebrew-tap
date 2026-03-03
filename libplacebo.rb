class Libplacebo < Formula
  include Language::Python::Virtualenv

  desc "Reusable library for GPU-accelerated image/video processing primitives"
  homepage "https://code.videolan.org/videolan/libplacebo"
  url "https://code.videolan.org/videolan/libplacebo/-/archive/v7.360.0/libplacebo-v7.360.0.tar.bz2"
  sha256 "265a8888d4bc169b39c53315f1ba682249f2b0917e0438c1bb241aef822d8744"
  license "LGPL-2.1-or-later"
  compatibility_version 1
  head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"

  depends_on "fast_float" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.14" => :build
  depends_on "vulkan-headers" => :build

  depends_on "deus0ww/tap/dovi_tool"
  depends_on "little-cms2"
  depends_on "shaderc"
  depends_on "vulkan-loader"
  depends_on "xxhash"

  resource "glad2" do
    url "https://files.pythonhosted.org/packages/6e/5a/d62b24fe1c7c2f34e15c2aa4418a5327a8550fdc272999a59e0dddebc3ee/glad2-2.0.8.tar.gz"
    sha256 "b84079b9fa404f37171b961bdd1d8da21370e6c818defb8481c5b3fe3d6436da"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz"
    sha256 "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/7e/99/7690b6d4034fffd95959cbe0c02de8deb3098cc577c67bb6a24fe5d7caa7/markupsafe-3.0.3.tar.gz"
    sha256 "722695808f4b6457b320fdc131280796bdceb04ab50fe1795cd540799ebe1698"
  end

  def install
    resources.each do |r|
      # Override resource name to use expected directory name
      dir_name = case r.name
      when "glad2", "jinja2"
        r.name.sub(/\d+$/, "")
      else
        r.name
      end

      r.stage(Pathname("3rdparty")/dir_name)
    end

    # Use Homebrew `fast_float`.
    inreplace "src/meson.build", "../3rdparty/fast_float/include", Formula["fast_float"].opt_include

    args = %w[
      -Db_lto=true
      -Db_lto_mode=thin
      -Ddemos=false

      -Dlcms=enabled
      -Dopengl=enabled
      -Dshaderc=enabled
      -Dvulkan=enabled
      -Dvulkan-registry=#{Formula["vulkan-headers"].share}/vulkan/registry/vk.xml
    ]
    args << ("-Dc_args=" + (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast")

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libplacebo/config.h>
      #include <stdlib.h>
      int main() {
        return (pl_version() != NULL) ? 0 : 1;
      }
    C
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lplacebo"
    system "./test"
  end
end
