TARGET=${TARGET_ARCH}${TARGET_VENDOR:-}-${TARGET_OS}
host_arch=x86_64
host_os="$TRAVIS_OS_NAME"
case "$host_os" in
  linux)
    host_vendor=-unknown
    host_os=linux-gnu
    ;;
  osx)
    host_vendor=-apple
    host_os=darwin
    ;;
esac
host=${host_arch}${host_vendor:-}-${host_os}
PROJECT_NAME="$PROJECT_BASE/${TARGET}/${TRAVIS_RUST_VERSION}"

run_cargo() {
  if [ -n "$FEATURES" ]; then
    cargo "$@" --verbose --target="$TARGET" --features="$FEATURES"
  else
    cargo "$@" --verbose --target="$TARGET"
  fi
}

