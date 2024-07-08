class Libplacebo < Formula
  include Language::Python::Virtualenv

  desc "Reusable library for GPU-accelerated image/video processing primitives"
  homepage "https://code.videolan.org/videolan/libplacebo"
  license "LGPL-2.1-or-later"

  if MacOS.version > :mojave
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v7.349.0/libplacebo-v7.349.0.tar.bz2"
    sha256 "38c9c75d9c1bb412baf34845d1ca58c41a9804d1d0798091d7a8602a0d7c9aa6"
    head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"
  elsif MacOS.version == :mojave # With incompatible commits reverted
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v7.349.0/libplacebo-v7.349.0.tar.bz2"
    sha256 "38c9c75d9c1bb412baf34845d1ca58c41a9804d1d0798091d7a8602a0d7c9aa6"
    head "https://code.videolan.org/videolan/libplacebo.git", branch: "master"
    patch do # Revert convert.cc changes that's incompatible with C++17 on macOS < 10.15
      url "https://github.com/deus0ww/homebrew-tap/raw/master/patches/libplacebo-10.14.patch"
      sha256 "56c4861d28ce1200d75f9776bfa89b21dc48ac5a2fa9aba5981c8be75b601e5f"
    end
  else # Last Official Version for macOS < 10.15
    url "https://code.videolan.org/videolan/libplacebo/-/archive/v6.292.1/libplacebo-v6.292.1.tar.bz2"
    sha256 "51f0b7b400b35ce5f131a763c0cebb8e46680c17bed58cc9296b20c603f7f65f"
    head do # Last buildable commit on macOS 10.13 - v.6.318
      url "https://code.videolan.org/videolan/libplacebo/-/archive/0df53c2e23ab04a4c213085a9aaaef342c8214ff/libplacebo-0df53c2e23ab04a4c213085a9aaaef342c8214ff.tar.bz2"
      sha256 "b8eb1c34b7584b0286054ca7879af37ea039db2adaa884fb4cb902c74fddffae"
      patch do # Extra changes needed to apply first patch on macOS 10.13
        url "https://github.com/deus0ww/homebrew-tap/raw/master/patches/libplacebo-10.13.patch"
        sha256 "124d74ab62dcda482671a020575dea58d9aeecf8eec6e93162bf49f35122f2a2"
      end
      patch do # Revert convert.cc changes that's incompatible with C++17 on macOS < 10.15
        url "https://github.com/deus0ww/homebrew-tap/raw/master/patches/libplacebo-10.14.patch"
        sha256 "56c4861d28ce1200d75f9776bfa89b21dc48ac5a2fa9aba5981c8be75b601e5f"
      end
    end
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.12" => :build
  depends_on "vulkan-headers" => :build

  if MacOS.version > :mojave
    depends_on "deus0ww/tap/dovi_tool"
    depends_on "molten-vk"
    depends_on "shaderc"
  elsif MacOS.version == :mojave
    depends_on "deus0ww/tap/molten-vk"
    depends_on "deus0ww/tap/shaderc"
  else
    depends_on "deus0ww/tap/shaderc"
  end

  depends_on "little-cms2"
  depends_on "vulkan-loader"
  depends_on "xxhash"

  resource "fast_float" do
    url "https://github.com/fastfloat/fast_float/archive/refs/tags/v6.1.1.tar.gz"
    sha256 "10159a4a58ba95fe9389c3c97fe7de9a543622aa0dcc12dd9356d755e9a94cb4"
  end

  resource "glad2" do
    url "https://files.pythonhosted.org/packages/15/fc/9235e54b879487f7479f333feddf16ac8c1f198a45ab2e96179b16f17679/glad2-2.0.6.tar.gz"
    sha256 "08615aed3219ea1c77584bd5961d823bab226f8ac3831d09adf65c6fa877f8ec"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/ed/55/39036716d19cab0747a5020fc7e907f362fbf48c984b14e62127f7e68e5d/jinja2-3.1.4.tar.gz"
    sha256 "4a3aee7acbbe7303aede8e9648d13b8bf88a429282aa6122a993f0ac800cb369"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/87/5b/aae44c6655f3801e81aa3eef09dbbf012431987ba564d7231722f68df02d/MarkupSafe-2.1.5.tar.gz"
    sha256 "d283d37a890ba4c1ae73ffadf8046435c76e7bc2247bbb63c00bd1a709c6544b"
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
