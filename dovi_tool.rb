class DoviTool < Formula
  desc "CLI tool for Dolby Vision metadata on video streams"
  homepage "https://github.com/quietvoid/dovi_tool/"
  url "https://github.com/quietvoid/dovi_tool/archive/refs/tags/2.3.0.tar.gz"
  sha256 "2c76f8c7a17ff6af71c168bc9b041e94efe89b4f91ccde2f3f208c821037069c"
  license "MIT"
  head "https://github.com/quietvoid/dovi_tool.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cargo-c" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "fontconfig"
    depends_on "freetype"
  end

  def install
    system "cargo", "install", *std_cargo_args
    pkgshare.install "assets"
    cd "dolby_vision" do
      system "cargo", "cinstall", "--prefix", prefix
    end
  end

  test do
    output = shell_output("#{bin}/dovi_tool info #{pkgshare}/assets/hevc_tests/regular_rpu.bin --frame 0")
    assert_match <<~EOS, output
      Parsing RPU file...
      {
        "dovi_profile": 8,
        "header": {
          "rpu_nal_prefix": 25,
    EOS

    assert_match "dovi_tool #{version}", shell_output("#{bin}/dovi_tool --version")
  end
end
