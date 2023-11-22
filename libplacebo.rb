class Libplacebo < Formula
  include Language::Python::Virtualenv

  desc "Reusable library for GPU-accelerated image/video processing primitives"
  homepage "https://code.videolan.org/videolan/libplacebo"
  license "LGPL-2.1-or-later"

  if MacOS.version >= :big_sur
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v6.338.1/libplacebo-v6.338.1.tar.bz2"
    sha256 "66f173e511884ad96c23073e6c3a846215db804f098e11698132abe5a63d6f72"
    head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"
  elsif MacOS.version == :mojave
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v6.338.1/libplacebo-v6.338.1.tar.bz2"
    sha256 "66f173e511884ad96c23073e6c3a846215db804f098e11698132abe5a63d6f72"
    head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"
    patch do # Revert convert.cc changes that's incompatible with C++17 on macOS < 10.15
      url "https://github.com/deus0ww/homebrew-tap/raw/master/libplacebo-10.14.patch"
      sha256 "dd3824540dea6133810fa649630a2861b47e818e036f8076d9d69577145fb131"
    end
  else
    # Last Official Version for macOS < 10.15
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v6.292.1/libplacebo-v6.292.1.tar.bz2"
    sha256 "51f0b7b400b35ce5f131a763c0cebb8e46680c17bed58cc9296b20c603f7f65f"
    head do # Last buildable commit on macOS 10.13 - v.6.318
      url "https://code.videolan.org/videolan/libplacebo/-/archive/0df53c2e23ab04a4c213085a9aaaef342c8214ff/libplacebo-0df53c2e23ab04a4c213085a9aaaef342c8214ff.tar.bz2"
      sha256 "b8eb1c34b7584b0286054ca7879af37ea039db2adaa884fb4cb902c74fddffae"
      patch do # Extra changes needed to apply first patch on macOS 10.13
        url "https://github.com/deus0ww/homebrew-tap/raw/master/libplacebo-10.13.patch"
        sha256 "124d74ab62dcda482671a020575dea58d9aeecf8eec6e93162bf49f35122f2a2"
      end
      patch do # Revert convert.cc changes that's incompatible with C++17 on macOS < 10.15
        url "https://github.com/deus0ww/homebrew-tap/raw/master/libplacebo-10.14.patch"
        sha256 "dd3824540dea6133810fa649630a2861b47e818e036f8076d9d69577145fb131"
      end
    end
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.12" => :build
  depends_on "vulkan-headers" => :build

  if MacOS.version >= :big_sur
    depends_on "deus0ww/tap/dovi_tool"
    depends_on "shaderc"
  else
    depends_on "deus0ww/tap/shaderc"
  end

  depends_on "little-cms2"
  depends_on "python-markupsafe"
  depends_on "vulkan-loader"
  depends_on "xxhash"

  resource "fast_float" do
    url "https://github.com/fastfloat/fast_float/archive/refs/tags/v5.2.0.tar.gz"
    sha256 "72bbfd1914e414c920e39abdc81378adf910a622b62c45b4c61d344039425d18"
  end

  resource "glad2" do
    url "https://files.pythonhosted.org/packages/8b/b3/191508033476b6a409c070c6166b1c41ebb547cc6136260e9157343e6a2b/glad2-2.0.4.tar.gz"
    sha256 "ede1639f69f2ba08f1f498a40a707f34a609d24eb2ea0d6c9364689a798cf7d0"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/7a/ff/75c28576a1d900e87eb6335b063fab47a8ef3c8b4d88524c4bf78f670cce/Jinja2-3.1.2.tar.gz"
    sha256 "31351a702a408a9e7595a8fc6150fc3f43bb6bf7e319770cbc0db9df9437e852"
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

    args = %w[
      -Db_lto=true
      -Db_lto_mode=thin
      -Ddemos=false

      -Dvulkan=enabled
      -Dopengl=enabled
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
