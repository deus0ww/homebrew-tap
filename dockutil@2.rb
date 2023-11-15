class DockutilAT2 < Formula
  desc "Tool for managing dock items"
  homepage "https://github.com/kcrawford/dockutil"
  url "https://github.com/kcrawford/dockutil/archive/refs/tags/2.0.5.tar.gz"
  sha256 "6dbbc1467caaab977bf4c9f2d106ceadfedd954b6a4848c54c925aff81159a65"
  license "Apache-2.0"

  head do
    url "https://github.com/kcrawford/dockutil.git", branch: "main"

    depends_on xcode: ["13.0", :build]

    uses_from_macos "swift"
  end

  # https://github.com/kcrawford/dockutil/pull/131
  # https://github.com/Homebrew/homebrew-core/pull/97394
  # deprecate! date: "2023-09-03", because: :does_not_build

  depends_on :macos

  def install
    if build.head?
      system "swift", "build", "--disable-sandbox", "--configuration", "release"
      bin.install ".build/release/dockutil"
    else
      bin.install "scripts/dockutil"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dockutil --version")
  end
end
