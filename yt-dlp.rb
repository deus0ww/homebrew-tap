class YtDlp < Formula
  include Language::Python::Virtualenv

  desc "Download YouTube videos from the command-line"
  homepage "https://github.com/yt-dlp/yt-dlp"
  url "https://github.com/yt-dlp/yt-dlp/archive/2021.03.07.tar.gz"
  sha256 "16c03bcc4e0ff81ef73e4bee4fe3c6d74b41fed5891a10c0293bd7e7f23a5f1d"
  license "Unlicense"
  head "https://github.com/yt-dlp/yt-dlp.git"

  depends_on "pandoc"
  depends_on "python@3.9"
  depends_on "zip"

  def install
    system "make"
    virtualenv_install_with_resources
    man1.install_symlink libexec/"share/man/man1/yt-dlp.1" => "yt-dlp.1"
    bash_completion.install libexec/"share/bash-completion/completions/yt-dlp"
    fish_completion.install libexec/"share/fish/vendor_completions.d/yt-dlp.fish"
  end

  test do
    # commit history of homebrew-core repo
    system "#{bin}/yt-dlp", "--simulate", "https://www.youtube.com/watch?v=pOtd1cbOP7k"
    # homebrew playlist
    system "#{bin}/yt-dlp", "--simulate", "--yes-playlist", "https://www.youtube.com/watch?v=pOtd1cbOP7k&list=PLMsZ739TZDoLj9u_nob8jBKSC-mZb0Nhj"
  end
end
