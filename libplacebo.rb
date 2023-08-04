class Libplacebo < Formula
  include Language::Python::Virtualenv

  desc "Reusable library for GPU-accelerated image/video processing primitives"
  homepage "https://code.videolan.org/videolan/libplacebo"
  url "https://code.videolan.org/videolan/libplacebo/-/archive/v6.292.1/libplacebo-v6.292.1.tar.bz2"
  sha256 "51f0b7b400b35ce5f131a763c0cebb8e46680c17bed58cc9296b20c603f7f65f"
  license "LGPL-2.1-or-later"
  head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python@3.11" => :build
  depends_on "vulkan-headers" => :build

  depends_on "glslang"
  depends_on "little-cms2"
  depends_on "sdl2"
  depends_on "vulkan-loader"

  resource "glad" do
    url "https://files.pythonhosted.org/packages/8b/b3/191508033476b6a409c070c6166b1c41ebb547cc6136260e9157343e6a2b/glad2-2.0.4.tar.gz"
    sha256 "ede1639f69f2ba08f1f498a40a707f34a609d24eb2ea0d6c9364689a798cf7d0"
  end

  resource "jinja" do
    url "https://files.pythonhosted.org/packages/7a/ff/75c28576a1d900e87eb6335b063fab47a8ef3c8b4d88524c4bf78f670cce/Jinja2-3.1.2.tar.gz"
    sha256 "31351a702a408a9e7595a8fc6150fc3f43bb6bf7e319770cbc0db9df9437e852"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/6d/7c/59a3248f411813f8ccba92a55feaac4bf360d29e2ff05ee7d8e1ef2d7dbf/MarkupSafe-2.1.3.tar.gz"
    sha256 "af598ed32d6ae86f1b747b82783958b1a4ab8f617b06fe68795c7f026abbdcad"
  end

  def install
    resources.each do |r|
      r.stage(Pathname("3rdparty")/r.name)
    end

    args = %w[
      -Db_lto=true
      -Db_lto_mode=thin
      -Ddemos=false
    ]
    args << ("-Dc_args=" + (Hardware::CPU.arm? ? "-mcpu=native" : "-march=native -mtune=native") + " -Ofast")

    system "meson", "setup", "build",
                    "-Dvulkan-registry=#{Formula["vulkan-headers"].share}/vulkan/registry/vk.xml",
                    *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libplacebo/config.h>
      #include <stdlib.h>
      int main() {
        return (pl_version() != NULL) ? 0 : 1;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lplacebo"
    system "./test"
  end
end
