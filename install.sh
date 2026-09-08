#!/usr/bin/env bash
# Instala o GitFind em ~/.local/bin e registra o lançador no menu.
set -euo pipefail
cd "$(dirname "$0")"

BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
mkdir -p "$BIN" "$APPS"

install -m 755 gitfind gitfind-gui "$BIN/"
sed "s|^Exec=gitfind-gui$|Exec=$BIN/gitfind-gui|" gitfind.desktop > "$APPS/gitfind.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null || true

case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "aviso: $BIN não está no PATH."
     echo "       adicione ao ~/.bashrc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo "GitFind instalado."
command -v gh   >/dev/null || echo "faltando: gh   (sudo apt install gh)  — obrigatório"
command -v fzf  >/dev/null || echo "faltando: fzf  (sudo apt install fzf) — opcional, modo interativo"
python3 -c "import gi" 2>/dev/null || echo "faltando: python3-gi (sudo apt install python3-gi) — para a GUI"
gh auth status >/dev/null 2>&1 || echo "atenção: rode 'gh auth login' antes de usar"
