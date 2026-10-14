# Contributing to the neotools tap

This repository holds the Homebrew formula of [neotools](https://github.com/reachdevel/neotools). Problems with neotools itself (a
command prints something wrong, a crash, a feature request) belong in the
[neotools issues](https://github.com/reachdevel/neotools/issues); problems with installing it through Homebrew belong here.

## Changing the formula

1. Open a pull request that changes `Formula/neotools.rb`. A new release is a new `url` and `sha256` (the checksum of the tag's
   source archive) and no `bottle` block: the bottles are made again.
2. The `brew test-bot` workflow builds the formula on macOS 15 and 26 (Apple silicon) and macOS 15 (Intel), runs `brew test` and
   `brew audit`, and uploads the bottles. All jobs must be green, and the job log must not say `FAILED`.
3. A maintainer runs the `brew pr-pull` workflow with the pull request number; it publishes the bottles to a release of this
   repository and adds the `bottle` block to `main`.

Check it locally first:

```sh
brew style reachdevel/tap/neotools
brew audit --strict --online reachdevel/tap/neotools
brew install --build-from-source reachdevel/tap/neotools && brew test reachdevel/tap/neotools
```

Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).
