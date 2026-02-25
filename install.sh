#!/usr/bin/env bash
# install.sh — Installs claude-reset-loop

set -euo pipefail

REPO="dangerouslyskippermissions/claude-reset-loop"
RAW="https://raw.githubusercontent.com/$REPO/main"
BIN_DIR="${HOME}/.local/bin"
CMD="claude-reset-loop"

# Ensure the bin directory exists
mkdir -p "$BIN_DIR"

echo "Installing $CMD..."
curl -fsSL "$RAW/claude-reset-loop.sh" -o "$BIN_DIR/$CMD"
chmod +x "$BIN_DIR/$CMD"

# Add to PATH if not already there
add_to_path() {
  local rc="$1"
  if [[ -f "$rc" ]] && ! grep -q "$BIN_DIR" "$rc"; then
    echo "" >> "$rc"
    echo "# claude-reset-loop" >> "$rc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$rc"
    echo "  Added $BIN_DIR to PATH in $rc"
  fi
}

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  add_to_path "$HOME/.zshrc"
  add_to_path "$HOME/.bashrc"
  echo ""
  echo "Restart your terminal or run:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "Done. Run it with:"
echo "  $CMD -f your-instructions.md"
