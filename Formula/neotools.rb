class Neotools < Formula
  desc "Native macOS replacements for du, df, top, find, lsof, ps and rm"
  homepage "https://github.com/reachdevel/neotools"
  url "https://github.com/reachdevel/neotools/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "9b9c2091905122c540c8a0edc2c26eba44cc4c80bfa30cc4ab12d21e10fee68f"
  license "MIT"
  head "https://github.com/reachdevel/neotools.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
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
