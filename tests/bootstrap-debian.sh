#!/usr/bin/env bash
# AC 1–7: bootstrap-debian.sh dry-run, os check, apt mock, install.sh gate.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOT="$ROOT/bootstrap-debian.sh"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "PASS: $*"; }

debian_os="$(mktemp)"
ubuntu_os="$(mktemp)"
cat >"$debian_os" <<'EOF'
ID=debian
ID_LIKE=debian
EOF
cat >"$ubuntu_os" <<'EOF'
ID=fedora
ID_LIKE=fedora
EOF

# AC1 dry-run prints core packages, no apt
apt_log="$(mktemp)"
cat >"$apt_log.mock" <<'EOF'
#!/usr/bin/env bash
echo "apt $*" >>"${APT_LOG:?}"
exit 0
EOF
chmod +x "$apt_log.mock"

out="$(BOOTSTRAP_OS_RELEASE="$debian_os" BOOTSTRAP_APT="$apt_log.mock" APT_LOG="$apt_log" \
  bash "$BOOT" --dry-run)"
if echo "$out" | grep -qx i3 \
  && echo "$out" | grep -qx kitty \
  && echo "$out" | grep -qx fish \
  && echo "$out" | grep -qx tmux \
  && echo "$out" | grep -qx redshift \
  && echo "$out" | grep -qx neovim; then
  pass "dry-run lists core packages"
else
  fail "dry-run missing core packages (got: $(echo "$out" | tr '\n' ' '))"
fi
if [[ -s "$apt_log" ]]; then
  fail "dry-run must not invoke apt (log: $(cat "$apt_log"))"
else
  pass "dry-run skips apt"
fi

# AC2 x11 packages present
if echo "$out" | grep -qx xorg && echo "$out" | grep -qx lightdm; then
  pass "dry-run lists xorg/lightdm"
else
  fail "dry-run missing xorg/lightdm"
fi

# AC3 --skip-x11
out_nox="$(BOOTSTRAP_OS_RELEASE="$debian_os" bash "$BOOT" --dry-run --skip-x11)"
if echo "$out_nox" | grep -qx lightdm; then
  fail "--skip-x11 still prints lightdm"
else
  pass "--skip-x11 omits lightdm"
fi
if echo "$out_nox" | grep -qx i3; then
  pass "--skip-x11 still lists i3"
else
  fail "--skip-x11 dropped i3"
fi

# AC4 non-debian
set +e
BOOTSTRAP_OS_RELEASE="$ubuntu_os" bash "$BOOT" --dry-run >/dev/null 2>"$apt_log.err"
rc=$?
set -e
if [[ "$rc" -eq 2 ]]; then
  pass "non-debian exits 2"
else
  fail "non-debian exit $rc want 2"
fi

# AC5 mocked apt install
: >"$apt_log"
BOOTSTRAP_OS_RELEASE="$debian_os" BOOTSTRAP_APT="$apt_log.mock" APT_LOG="$apt_log" \
  bash "$BOOT" --skip-chsh --skip-dotfiles --skip-x11 >/dev/null
if grep -q 'update' "$apt_log" && grep -q 'install -y' "$apt_log" && grep -q ' i3' "$apt_log"; then
  pass "apt mock got update + install -y i3"
else
  fail "apt mock log: $(tr '\n' ' ' <"$apt_log")"
fi

# AC6 / AC7 install.sh gate
install_log="$(mktemp)"
fake_install="$(mktemp)"
cat >"$fake_install" <<'EOF'
#!/usr/bin/env bash
echo invoked >>"${INSTALL_LOG:?}"
EOF
chmod +x "$fake_install"

: >"$install_log"
BOOTSTRAP_OS_RELEASE="$debian_os" BOOTSTRAP_APT="$apt_log.mock" APT_LOG="$apt_log" \
  BOOTSTRAP_INSTALL="$fake_install" INSTALL_LOG="$install_log" \
  bash "$BOOT" --skip-chsh --skip-x11 >/dev/null
if grep -q invoked "$install_log"; then
  pass "default run invokes install.sh"
else
  fail "install.sh not invoked"
fi

: >"$install_log"
BOOTSTRAP_OS_RELEASE="$debian_os" BOOTSTRAP_APT="$apt_log.mock" APT_LOG="$apt_log" \
  BOOTSTRAP_INSTALL="$fake_install" INSTALL_LOG="$install_log" \
  bash "$BOOT" --skip-chsh --skip-x11 --skip-dotfiles >/dev/null
if [[ -s "$install_log" ]]; then
  fail "--skip-dotfiles still invoked install.sh"
else
  pass "--skip-dotfiles skips install.sh"
fi

# AC8 vendor apps never in apt lists
vendor_re='chrome|chromium|discord|slack|spotify|postman|android-studio|obsidian|^cursor$'
if echo "$out" | grep -Eiq "$vendor_re" \
  || grep -Eiv '^[[:space:]]*#' "$ROOT/debian/packages.txt" "$ROOT/debian/packages-x11.txt" | grep -Eiq "$vendor_re"; then
  fail "vendor apps must not be in bootstrap package lists"
else
  pass "no Chrome/Cursor/Discord/Slack/Spotify/Postman/Studio/Obsidian in apt lists"
fi

exit "$FAIL"
