class MpvBashCompletion < Formula
  desc "Bash completion for the mpv video player"
  homepage "https://github.com/2ion/mpv-bash-completion"
  url "https://github.com/2ion/mpv-bash-completion/archive/3.3.17.tar.gz"
  sha256 "355f9ae90638c730028e0b6a3ae6e9c09f5cb1ede27372f8a8cf7b0035020e97"
  head "https://github.com/deus0ww/mpv-bash-completion.git"

  depends_on "bash"
  depends_on "coreutils"
  depends_on "deus0ww/tap/luajit"
  depends_on "deus0ww/tap/mpv"

  def install
    system "make", "-f", "Makefile.osx"
    system "make", "-f", "Makefile.osx", "install", "PREFIX=#{prefix}"
  end
end
