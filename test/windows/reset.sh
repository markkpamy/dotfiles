#!/usr/bin/env bash
# Linux host: save or restore the clean-Windows disk of the dotfiles test VM.
# (On a Windows host use reset.ps1.)
#   ./reset.sh save      stop the VM and copy its disk to GOLDEN_DIR
#   ./reset.sh restore   put the golden disk back and start the VM
#   ./reset.sh status    show both folders
# The downloaded ISO is left in place, so a restore never re-downloads Windows.
set -euo pipefail
cd "$(dirname "$0")"

[[ -f .env ]] || { echo "Missing .env: copy .env.linux.example first." >&2; exit 1; }
set -a; source .env; set +a
: "${STORAGE_DIR:?set STORAGE_DIR in .env}" "${GOLDEN_DIR:?set GOLDEN_DIR in .env}"

sync_disk() { # src dst
  mkdir -p "$2"
  rsync -a --sparse --delete --exclude '*.iso' "$1"/ "$2"/
}

case "${1:-}" in
  save)
    docker compose stop
    sync_disk "$STORAGE_DIR" "$GOLDEN_DIR"
    echo "Golden image saved to $GOLDEN_DIR"
    ;;
  restore)
    [[ -n "$(ls -A "$GOLDEN_DIR" 2>/dev/null)" ]] || { echo "No golden image in $GOLDEN_DIR: run './reset.sh save' after the first install." >&2; exit 1; }
    docker compose down
    sync_disk "$GOLDEN_DIR" "$STORAGE_DIR"
    docker compose up -d
    echo "Restored. Connect via RDP (port ${RDP_PORT:-3389}) or http://<this-host>:${WEB_PORT:-8006}"
    ;;
  status)
    du -sh --apparent-size "$STORAGE_DIR" "$GOLDEN_DIR" 2>/dev/null || true
    ls -la "$GOLDEN_DIR" 2>/dev/null || echo "No golden image yet."
    ;;
  *)
    echo "Usage: $0 save|restore|status" >&2; exit 2 ;;
esac
