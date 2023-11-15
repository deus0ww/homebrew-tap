class DockutilAT3 < Formula
  desc "Tool for managing dock items"
  homepage "https://github.com/kcrawford/dockutil"
  license "Apache-2.0"

  head do
    url "https://github.com/kcrawford/dockutil.git", branch: "main"

    depends_on xcode: ["13.0", :build]

    uses_from_macos "swift"
  end

  depends_on :macos

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/dockutil"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dockutil --version")
  end
end
