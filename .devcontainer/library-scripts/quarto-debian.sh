#!/usr/bin/env bash

# This script installs Quarto

set -e

QUARTO_VERSION=${1:-"1.3.26"}
SCRIPT=("${BASH_SOURCE[@]}")
SCRIPT_PATH="${SCRIPT##*/}"
SCRIPT_NAME="${SCRIPT_PATH%.*}"
MARKER_FILE="/usr/local/etc/devcontainer-markers/${SCRIPT_NAME}"
MARKER_FILE_DIR=$(dirname "${MARKER_FILE}")

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

function apt_get_update_if_needed() {
  if [[ -d "/var/lib/apt/lists" && $(ls /var/lib/apt/lists/ | wc -l) -eq 0 ]]; then
    apt-get update
  fi
}

function check_packages() {
  if ! dpkg --status "$@" >/dev/null 2>&1; then
    apt_get_update_if_needed
    apt-get install --no-install-recommends --assume-yes "$@"
  fi
}

function quarto_inst() {
  case "$OSTYPE" in
  linux-*)
    OS=linux
    ;;
  esac
  machine=$(uname -m)
  case "$machine" in
  x86_64)
    ARCH=amd64
    ;;
  esac
  wget -c https://github.com/quarto-dev/quarto-cli/releases/download/v"$QUARTO_VERSION"/quarto-"$QUARTO_VERSION"-$OS-$ARCH.deb &&
    dpkg -i quarto-"$QUARTO_VERSION"-$OS-$ARCH.deb &&
    rm quarto-"$QUARTO_VERSION"-$OS-$ARCH.deb
}

if [ -f "${MARKER_FILE}" ]; then
  echo "Marker file found:"
  cat "${MARKER_FILE}"
  # shellcheck source=/dev/null
  source "${MARKER_FILE}"
fi

export DEBIAN_FRONTEND=noninteractive

if [ "${QUARTO_ALREADY_INSTALLED}" != "true" ]; then
  check_packages \
    wget
  quarto_inst

  QUARTO_ALREADY_INSTALLED="true"
fi

if [ ! -d "$MARKER_FILE_DIR" ]; then
  mkdir -p "$MARKER_FILE_DIR"
fi

echo -e "\
    QUARTO_ALREADY_INSTALLED=${QUARTO_ALREADY_INSTALLED}" >"${MARKER_FILE}"
