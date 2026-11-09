class Neotools < Formula
  desc "macOS replacements for du, df, top, find, lsof, ps, rm and a disk cleaner"
  homepage "https://github.com/reachdevel/neotools"
  url "https://github.com/reachdevel/neotools/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "0dfbfeac873848e951a7a2cce6201ce06ab3c45c445eabebf1a66383ef9e31b4"
  license "MIT"
  head "https://github.com/reachdevel/neotools.git", branch: "main"

  bottle do
    root_url "https://github.com/reachdevel/homebrew-tap/releases/download/neotools-0.2.1"
    sha256                               arm64_tahoe:   "2eca5602d8d3ce6b1e52c9c4d7bab2f0afe06435cf14d0fe4f15a43748d2b668"
    sha256                               arm64_sequoia: "1be944c47a7178d0a901df4972717065669d5f33a5a7a6891bca53299a80d9b8"
    sha256 cellar: :any_skip_relocation, sequoia:       "974b33c936f550c7a86eb68dc1b410d9a8c7810e10ec88e60bd4b929baf9114a"
  end

  depends_on macos: :sonoma

  def install
    # Swift 6 ships with the Command Line Tools (16 or newer) as well as with Xcode,
    # so the full Xcode app is not needed.
    swift_major = Utils.safe_popen_read("swift", "--version")[/Swift version (\d+)/, 1].to_i
    if swift_major < 6
      odie "neotools needs Swift 6: update the Command Line Tools (Software Update, or " \
           "`sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install`)."
    end

    system "swift", "build", "--configuration", "release", "--disable-sandbox"

    commands = %w[
      neo-setup neodf neodocs neodu neofind neofree neolsof
      neomedia neonet neops neosweep neotop neotrash neotree
    ]
    # The translations (neotools_NeoCore.bundle) must sit next to the commands,
    # and a command finds them through its own real path, so the commands live in
    # libexec and bin holds symlinks to them.
    libexec.install commands.map { |c| ".build/release/#{c}" }
    libexec.install ".build/release/neotools_NeoCore.bundle"
    commands.each { |c| bin.install_symlink libexec/c }
  end

  def caveats
    <<~EOS
      neotools is installed: neodu, neodf, neotop, neofree, neotrash, neofind,
      neolsof, neotree, neops, neonet, neomedia, neodocs, neosweep and neo-setup.

      Try:
        neodf            your disks, the way Finder sees them
        neotop --once    which apps use the power right now
        neosweep         what can be deleted, and what it really frees

      To type "du" and get "neodu" (removable at any time):
        neo-setup

      Before `brew uninstall neotools`, run `neo-setup --uninstall` if you used it.
    EOS
  end

  test do
    assert_match "neodu 0.2.1", shell_output("#{bin}/neodu --version")
    assert_match "neosweep 0.2.1", shell_output("#{bin}/neosweep --version")
    # the help comes from the translation bundle next to the commands
    with_env(NEO_LANG: "en") do
      assert_match "iCloud", shell_output("#{bin}/neodu --help")
    end
    assert_match "Mem:", shell_output("#{bin}/neofree")
    # text from the String Catalog (a build without Xcode's string compiler once printed bare keys)
    (testpath/"dir").mkpath
    touch testpath/"dir/a"
    touch testpath/"dir/b"
    out = shell_output("#{bin}/neotree --plain #{testpath}/dir")
    assert_match "0 directories, 2 files", out
    refute_match "[tree.", out
  end
end
