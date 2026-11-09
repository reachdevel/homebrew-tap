class Neotools < Formula
  desc "macOS replacements for du, df, top, find, lsof, ps, rm and a disk cleaner"
  homepage "https://github.com/reachdevel/neotools"
  url "https://github.com/reachdevel/neotools/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "e945660ab160149337026f3037a9006b0a188a39b2791e139a1a4f73afc3ae27"
  license "MIT"
  head "https://github.com/reachdevel/neotools.git", branch: "main"

  bottle do
    root_url "https://github.com/reachdevel/homebrew-tap/releases/download/neotools-0.2.0"
    sha256                               arm64_tahoe:   "e76ba4d0de049e945ed499c50c3cb00393a6bccabb1b6ed5c0fd297531e2c19e"
    sha256                               arm64_sequoia: "7e948f75c3f90b91a8cd164df33eb1481471b46494e1d028a515d06d796d2884"
    sha256 cellar: :any_skip_relocation, sequoia:       "285917533821d825fb448e4622eeb2ebe16185ea6fe333d59eadbddaa4a735e0"
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
    assert_match "neodu 0.2.0", shell_output("#{bin}/neodu --version")
    assert_match "neosweep 0.2.0", shell_output("#{bin}/neosweep --version")
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
