class YtDlp < Formula
  include Language::Python::Virtualenv

  desc "Fork of youtube-dl with additional features and fixes"
  homepage "https://github.com/yt-dlp/yt-dlp"
  url "https://files.pythonhosted.org/packages/f8/ef/cdf55266ace06a9451e94a594dd57202910f86b24adfc5f5af4c66331322/yt-dlp-2022.9.1.tar.gz"
  sha256 "bc74ee255790043e458197aaf25c6c104fefc9fcda4458f652619447ab4ae0d7"
  license "Unlicense"
  head "https://github.com/yt-dlp/yt-dlp.git", branch: "master"

  depends_on "python@3.10"
  depends_on "aria2" => :recommended

  resource "Brotli" do
    url "https://files.pythonhosted.org/packages/2a/18/70c32fe9357f3eea18598b23aa9ed29b1711c3001835f7cf99a9818985d0/Brotli-1.0.9.zip"
    sha256 "4d1b810aa0ed773f81dceda2cc7b403d01057458730e309856356d4ef4188438"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/cb/a4/7de7cd59e429bd0ee6521ba58a75adaec136d32f91a761b28a11d8088d44/certifi-2022.9.24.tar.gz"
    sha256 "0d9c601124e5a6ba9712dbc60d9c53c21e34f5f641fe83002317394311bdce14"
  end

  resource "mutagen" do
    url "https://files.pythonhosted.org/packages/f3/d9/2232a4cb9a98e2d2501f7e58d193bc49c956ef23756d7423ba1bd87e386d/mutagen-1.45.1.tar.gz"
    sha256 "6397602efb3c2d7baebd2166ed85731ae1c1d475abca22090b7141ff5034b3e1"
  end

  resource "pycryptodomex" do
    url "https://files.pythonhosted.org/packages/52/0d/6cc95a83f6961a1ca041798d222240890af79b381e97eda3b9b538dba16f/pycryptodomex-3.15.0.tar.gz"
    sha256 "7341f1bb2dadb0d1a0047f34c3a58208a92423cdbd3244d998e4b28df5eac0ed"
  end

  resource "websockets" do
    url "https://files.pythonhosted.org/packages/f8/a3/622d9acbfb9a71144b5d7609906bc648c62e3ca5fdbb1c8cca222949d82c/websockets-10.3.tar.gz"
    sha256 "fc06cc8073c8e87072138ba1e431300e2d408f054b27047d047b549455066ff4"
  end

  def install
    if build.head?
      system "python3.10", "devscripts/update-version.py"
      system "python3.10", "devscripts/make_lazy_extractors.py"
      system "make", "lazy-extractors", "yt-dlp", "completions"
    end
    virtualenv_install_with_resources
    man1.install_symlink libexec/"share/man/man1/yt-dlp.1"
    bash_completion.install "completions/bash/yt-dlp"
    fish_completion.install "completions/fish/yt-dlp.fish"
    zsh_completion.install "completions/zsh/_yt-dlp"
  end

  test do
    # "History of homebrew-core", uploaded 3 Feb 2020
    system "#{bin}/yt-dlp", "--simulate", "https://www.youtube.com/watch?v=pOtd1cbOP7k"
    # "homebrew", playlist last updated 3 Mar 2020
    system "#{bin}/yt-dlp", "--simulate", "--yes-playlist", "https://www.youtube.com/watch?v=pOtd1cbOP7k&list=PLMsZ739TZDoLj9u_nob8jBKSC-mZb0Nhj"
  end
end
