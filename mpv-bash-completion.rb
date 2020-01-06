class MpvBashCompletion < Formula
  desc "Bash completion for the mpv video player"
  homepage "https://github.com/2ion/mpv-bash-completion"
  url "https://github.com/deus0ww/mpv-bash-completion/archive/3.3.18.tar.gz"
  sha256 "6ee2652bf44429e426cd6a1055961389795de14759f9ce0741cef95e4bb35f67"
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
