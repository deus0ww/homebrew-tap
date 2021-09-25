class YtDlp < Formula
  include Language::Python::Virtualenv

  desc "Youtube-dl fork with additional features and fixes"
  homepage "https://github.com/yt-dlp/yt-dlp"
  url "https://files.pythonhosted.org/packages/ad/2a/19788cdbce56ea05600068bf342f91c91fd5acc6c6486e16d498b0ec533a/yt-dlp-2021.9.25.tar.gz"
  sha256 "e7b8dd0ee9498abbd80eb38d9753696d6ca3d02f64980322ab3bf39ba1bc31ee"
  license "Unlicense"

  bottle :unneeded

  depends_on "python@3.9"
  depends_on "aria2" => :recommended

  def install
    virtualenv_install_with_resources
    bash_completion.install "completions/bash/yt-dlp"
    fish_completion.install "completions/fish/yt-dlp.fish"
    zsh_completion.install "completions/zsh/_yt-dlp"
  end

  test do
    # commit history of homebrew-core repo
    system "#{bin}/yt-dlp", "--simulate", "https://www.youtube.com/watch?v=pOtd1cbOP7k"
    # homebrew playlist
    system "#{bin}/yt-dlp", "--simulate", "--yes-playlist", "https://www.youtube.com/watch?v=pOtd1cbOP7k&list=PLMsZ739TZDoLj9u_nob8jBKSC-mZb0Nhj"
  end
end
