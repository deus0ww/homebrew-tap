class Dockutil < Formula
  desc "Tool for managing dock items"
  homepage "https://github.com/kcrawford/dockutil"
  license "Apache-2.0"

  if MacOS.version > :mojave
    url "https://github.com/kcrawford/dockutil/archive/refs/tags/3.1.2.tar.gz"
    sha256 "f21d30407473c7a9d6022225739c14faafa27a2a43c1a26643a7e5a4d508596a"
    head do
      url "https://github.com/kcrawford/dockutil.git", branch: "main"
      depends_on xcode: ["12.4", :build]
      uses_from_macos "swift"
    end
  else
    url "https://github.com/kcrawford/dockutil/archive/refs/tags/2.0.5.tar.gz"
    sha256 "6dbbc1467caaab977bf4c9f2d106ceadfedd954b6a4848c54c925aff81159a65"
  end

  depends_on :macos

  def install
    if MacOS.version > :mojave
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
