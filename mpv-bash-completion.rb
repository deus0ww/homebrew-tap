class MpvBashCompletion < Formula
  desc "Bash completion for the mpv video player"
  homepage "https://github.com/2ion/mpv-bash-completion"
  head "https://github.com/2ion/mpv-bash-completion.git"

  depends_on "deus0ww/tap/mpv"
  depends_on "bash"
  depends_on "coreutils"
  depends_on "lua"

  def install
    system "make", "-f", "Makefile.osx"
    system "make", "-f", "Makefile.osx", "install", "PREFIX=#{prefix}"
  end
end
