class Dockutil < Formula
  desc "Tool for managing dock items"
  homepage "https://github.com/kcrawford/dockutil"
  license "Apache-2.0"

  if MacOS.version > :big_sur
    url "https://github.com/kcrawford/dockutil/archive/805e288c5ae1787eb341ce8d0450cafed08a4627.tar.gz"
    sha256 "ad421621fcfa37d172bf1129c69ae4e67a2166fe7055ffb2992f028c97cdc61a"
    version "3.0.2.1"
    head do
      url "https://github.com/kcrawford/dockutil.git", branch: "main"
      depends_on xcode: ["13.0", :build]
      uses_from_macos "swift"
    end
  else
    url "https://github.com/kcrawford/dockutil/archive/refs/tags/2.0.5.tar.gz"
    sha256 "6dbbc1467caaab977bf4c9f2d106ceadfedd954b6a4848c54c925aff81159a65"
  end

  depends_on :macos

  def install
    if MacOS.version > :big_sur
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
