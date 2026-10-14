class Neotools < Formula
  desc "Native macOS replacements for du, df, top, find, lsof, ps and rm"
  homepage "https://github.com/reachdevel/neotools"
  url "https://github.com/reachdevel/neotools/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "7bd7506fefb06cfc025015c7ff9850a2d60367a50fbdddad8408c2f8ae50cad1"
  license "MIT"
  head "https://github.com/reachdevel/neotools.git", branch: "main"

  bottle do
    root_url "https://github.com/reachdevel/homebrew-tap/releases/download/neotools-0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "84404e838ec1d19498bf8dfbe8118e7d00a01b9e200d332e58662eaaf350c08f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0720ecc7157703577be42ec1028ac9f182baad9affc36a7ecc622fd81b07ce34"
    sha256 cellar: :any_skip_relocation, sequoia:       "7798498f1e0b238dc5303d062f2e7c129536e55751f4952b95dee676bc6f5937"
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
    assert_match "neodu 0.1.1", shell_output("#{bin}/neodu --version")
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
