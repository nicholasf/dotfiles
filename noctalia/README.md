# Noctalia notes

## TL;DR

Noctalia went through a full rewrite (v5): it's now a standalone native
C++/OpenGL ES Wayland shell, **not** a Quickshell config anymore. This
repo's `niri/config.kdl` still has the old (v4) Quickshell-based
autostart line, which is why the taskbar doesn't show up on a machine
where these dotfiles are deployed — there's nothing left for it to load.

## The stale line

`niri/config.kdl` (around line 254) currently has:

```
spawn-at-startup "qs" "-c" "noctalia-shell"
```

This is v4-era and does nothing under v5. Confirmed on gollum by running
it directly: `qs -c noctalia-shell` → "Could not find 'noctalia-shell'
config directory in any valid config path." There is no Quickshell-based
noctalia-shell config to find anymore — Quickshell isn't part of the v5
stack at all.

**Fix (not yet applied):** once the `noctalia` v5 binary is installed,
replace that line with:

```
spawn-at-startup "noctalia"
```

## Installing Noctalia v5

Fedora ships `noctalia` in its default repos starting at Fedora **44**.
For Fedora 43 (gollum's current release as of 2026-09-28), it needs a
Copr:

- `sudo dnf copr enable lionheartp/Hyprland && sudo dnf install noctalia-git`
  (Hyprland Community Copr, git snapshots)
- `sudo dnf copr enable zhangyi6324/noctalia-shell && sudo dnf install noctalia-shell`
  (alternative Copr mirror)

Package identity (from upstream `PACKAGING.md`): binary is `noctalia`,
desktop entry `dev.noctalia.Noctalia.desktop`.

This install step has not been done yet on gollum — only the
investigation and this note.

## Quickshell (separate, unrelated concern)

Quickshell 0.3.1 was installed on gollum via the
`errornointernet/quickshell` Copr (`sudo dnf copr enable
errornointernet/quickshell && sudo dnf install quickshell`) while
tracking down why the taskbar wasn't showing. **It is not needed for
Noctalia v5** — leave it installed only if something else on that
machine wants Quickshell specifically.

## Sources

- https://github.com/noctalia-dev/noctalia (README.md, PACKAGING.md)
- https://docs.noctalia.dev/noctalia/getting-started/installation/
- https://copr.fedorainfracloud.org/coprs/zhangyi6324/noctalia-shell/
