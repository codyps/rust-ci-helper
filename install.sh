#! /bin/bash
# `install` phase: install stuff needed for the `script` phase

set -ex

. "$(dirname "$0")/common.sh"

# Install rustup
curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain "$TRAVIS_RUST_VERSION"
rustup target add "$TARGET"

# Install standard libraries needed for cross compilation
if [ "$host" != "$TARGET" ]; then
  if [ "$TARGET" = "arm-unknown-linux-gnueabihf" ]; then
    # information about the cross compiler
    arm-linux-gnueabihf-gcc -v

    # tell cargo which linker to use for cross compilation
    mkdir -p .cargo
    cat >.cargo/config <<EOF
[target.$TARGET]
linker = "arm-linux-gnueabihf-gcc"
EOF
  fi
fi
