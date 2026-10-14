class Neotools < Formula
  desc "Native macOS replacements for du, df, top, find, lsof, ps and rm"
  homepage "https://github.com/reachdevel/neotools"
  url "https://github.com/reachdevel/neotools/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "9b9c2091905122c540c8a0edc2c26eba44cc4c80bfa30cc4ab12d21e10fee68f"
  license "MIT"
  revision 1
  head "https://github.com/reachdevel/neotools.git", branch: "main"

  bottle do
    root_url "https://github.com/reachdevel/homebrew-tap/releases/download/neotools-0.1.0_1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "303530a1be019f1a0da4744c251bd9dd872b6a3f4a0c049d7a9c4571e023c7b2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e9a43daf17a1314d68dbe3961daadbad1483b1bcb47df822d491f1512b3d644f"
    sha256 cellar: :any_skip_relocation, sequoia:       "60a726827e5b211031668198e07fa01f9b46e708988d9de5b962899d46800171"
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
      neomedia neonet neops neotop neotrash neotree
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
      neolsof, neotree, neops, neonet, neomedia, neodocs and neo-setup.

      Try:
        neodf            your disks, the way Finder sees them
        neotop --once    which apps use the power right now

      To type "du" and get "neodu" (removable at any time):
        neo-setup

      Before `brew uninstall neotools`, run `neo-setup --uninstall` if you used it.
    EOS
  end

  test do
    assert_match "neodu 0.1.0", shell_output("#{bin}/neodu --version")
    # the help comes from the translation bundle next to the commands
    with_env(NEO_LANG: "en") do
      assert_match "iCloud", shell_output("#{bin}/neodu --help")
    end
    assert_match "Mem:", shell_output("#{bin}/neofree")
  end
end
