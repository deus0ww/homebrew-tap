class DockutilAT3 < Formula
  desc "Tool for managing dock items"
  homepage "https://github.com/kcrawford/dockutil"
  url "https://github.com/kcrawford/dockutil/archive/refs/tags/3.0.2.tar.gz"
  sha256 "8d0117fccd836a14782107bdd3619df17dd4708470e3522f5b2ab0456769ba79"
  license "Apache-2.0"

  head do
    url "https://github.com/kcrawford/dockutil.git", branch: "main"

    depends_on xcode: ["13.0", :build]

    uses_from_macos "swift"
  end

  depends_on :macos

  # Create Package.swift
  patch :DATA unless build.head?

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

__END__
diff -urN a/Package.swift b/Package.swift
--- a/Package.swift	1969-12-31 19:00:00.000000000 -0500
+++ b/Package.swift	2022-03-22 17:56:20.000000000 -0400
@@ -0,0 +1,30 @@
+// swift-tools-version: 5.5
+// The swift-tools-version declares the minimum version of Swift required to build this package.
+
+import PackageDescription
+
+let package = Package(
+    name: "dockutil",
+    platforms: [
+        .macOS(.v12),
+    ],
+    dependencies: [
+        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"),
+    ],
+    targets: [
+        .executableTarget(
+            name: "dockutil",
+            dependencies: [
+               .product(name: "ArgumentParser", package: "swift-argument-parser"),
+            ],
+            path: "./dockutil",
+            exclude: ["Info.plist"]
+        ),
+        .testTarget(
+            name: "dockutilTests",
+            dependencies: ["dockutil"],
+            path: "./Tests",
+            exclude: ["Info.plist"]
+        ),
+    ]
+)
diff -urN a/dockutil/DockUtil.swift b/dockutil/DockUtil.swift
--- a/dockutil/DockUtil.swift	2022-03-22 13:33:57.000000000 -0400
+++ b/dockutil/DockUtil.swift	2022-03-22 17:56:46.000000000 -0400
@@ -10,7 +10,7 @@
 import ArgumentParser
 import Darwin

-let VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
+let VERSION = "3.0.2"
 var gv = 0 // Global verbosity

 struct DockAdditionOptions {
