#!/bin/bash
# ex: sts=2 sw=2 ts=2 et
# `script` phase: you usually build, test and generate docs in this phase

set -ex

. "$(dirname "$0")/common.sh"

export PKG_CONFIG_ALLOW_CROSS=1

# TODO modify this phase as you see fit
# PROTIP Always pass `--target $TARGET` to cargo commands, this makes cargo output build artifacts
# to target/$TARGET/{debug,release} which can reduce the number of needed conditionals in the
# `before_deploy`/packaging phase

export TARGET_CC=cc
RUN_COMPAT=true
if [ "$host" != "$TARGET" ]; then
  CROSS=true
  RUN_COMPAT=false
  # if the arch is the same, attempt to use the host compiler.
  # FIXME: not always correct to do so
  # Also try to use the host compiler if the arch has a 32vs64 bit differenct
  # FIXME: might also need to check that OS has a reasonable match
  if [ "$TARGET_ARCH" = arm ]; then
    export TARGET_CC="${TARGET_ARCH}-${TARGET_OS}-gcc"
  elif [ "$host_arch" != "$TARGET_ARCH" ] && \
    ! ( [ "$host_arch" == x86_64 ] && [ "$TARGET_ARCH" == i686 ] ); then
    export TARGET_CC=$TARGET-gcc
  fi

  if [ "$host_arch" == x86_64 ] && [ "$TARGET_ARCH" == i686 ]; then
    RUN_COMPAT=true
  fi

  if [ "$host_os" = "osx" ]; then
    brew install gnu-sed --default-names
  fi

  # NOTE Workaround for rust-lang/rust#31907 - disable doc tests when cross compiling
  find src -name '*.rs' -type f -exec sed -i -e 's:\(//.\s*```\):\1 ignore,:g' \{\} \;
fi

run_cargo build

if $RUN_COMPAT; then
  run_cargo test
  run_cargo bench
else
  # build tests but don't run them
  run_cargo test --no-run

  # run tests in emulator
  find "target/$TARGET/debug" -maxdepth 1 -executable -type f -fprintf /dev/stderr "test: %p" -print0 | xargs -0 qemu-$TARGET_ARCH -L /usr/$TARGET_ARCH-$TARGET_OS
fi
