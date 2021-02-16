# frozen_string_literal: true

class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.php"
  url "http://www.andre-simon.de/zip/highlight-3.61.tar.bz2"
  sha256 "b3d0b1fafffd01d45a96e8ac0e981d18814e7482df3f9e0b499c6be9e0d1a970"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/saalen/highlight.git"

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "deus0ww/tap/luajit"

  def install
    opts  = "-Ofast -march=native -mtune=native -flto=thin -funroll-loops -fomit-frame-pointer"
    opts += " -ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables"
    opts += " -fforce-emit-vtables" if MacOS.version >= :mojave
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    inreplace ["src/makefile"] do |s|
      s.gsub! /^(LUA_PKG_NAME)=(.*)$/, "\\1 = luajit"
    end

    conf_dir = etc/"highlight/" # highlight needs a final / for conf_dir
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}"
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}", "install"
  end

  test do
    system bin/"highlight", doc/"extras/highlight_pipe.php"
  end
end
