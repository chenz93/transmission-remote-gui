#!/usr/bin/env bash
# Read-only AppKit geometry regression test; no daemon, credentials or UI input.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/trgui-text-cell-layout.XXXXXX")"
trap 'rm -f "$TEST_DIR/test-text-cell-layout"; rmdir "$TEST_DIR"' EXIT
swiftc -swift-version 6 "$ROOT/Sources/TransmissionRemoteGUI/Views/TorrentTextCell.swift" \
    "$ROOT/Scripts/uitest/test_text_cell_layout.swift" -o "$TEST_DIR/test-text-cell-layout"
"$TEST_DIR/test-text-cell-layout"
