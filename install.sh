#!/usr/bin/env bash
#
# macOS Bootstrap — entry point
# Installs Homebrew, Ansible, and runs the bootstrap playbook.
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PLAYBOOK="${SCRIPT_DIR}/playbook.yaml"

log() {
  printf '\033[1;34m[bootstrap]\033[0m %s\n' "$*"
}

error() {
  printf '\033[1;31m[bootstrap]\033[0m ERROR: %s\n' "$*" >&2
}

# ---------------------------------------------------------------------------
# Ensure we are running on macOS
# ---------------------------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  error "This script must be run on macOS."
  exit 1
fi

# ---------------------------------------------------------------------------
# Install Homebrew if missing
# ---------------------------------------------------------------------------
install_homebrew() {
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if ! command -v brew &>/dev/null; then
  install_homebrew
else
  log "Homebrew is already installed."
fi

# ---------------------------------------------------------------------------
# Load Homebrew into the current shell (ARM64 vs Intel)
# ---------------------------------------------------------------------------
load_homebrew_env() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    # Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    # Intel
    eval "$(/usr/local/bin/brew shellenv)"
  else
    error "Homebrew binary not found after installation."
    exit 1
  fi
}

load_homebrew_env
log "Homebrew environment loaded ($(uname -m))."

# ---------------------------------------------------------------------------
# Install Ansible and required collections via Homebrew / ansible-galaxy
# ---------------------------------------------------------------------------
if ! command -v ansible-playbook &>/dev/null; then
  log "Installing Ansible via Homebrew..."
  brew install ansible
else
  log "Ansible is already installed."
fi

log "Ensuring Ansible community.general collection is installed..."
ansible-galaxy collection install community.general

# ---------------------------------------------------------------------------
# Run the bootstrap playbook
# ---------------------------------------------------------------------------
if [[ ! -f "${PLAYBOOK}" ]]; then
  error "Playbook not found at ${PLAYBOOK}"
  exit 1
fi

log "Running Ansible playbook..."
cd "${SCRIPT_DIR}"
ansible-playbook "${PLAYBOOK}"

log "Bootstrap complete."
