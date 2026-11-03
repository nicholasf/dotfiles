Config files.

The niri config.kdl has a configuration for the Framework Laptop 13 — AMD Ryzen AI 300 Series trackpad to enable right clicking.


## Troubleshooting

### `code .` does nothing in a tmux pane

VS Code (and any other GUI app) needs `WAYLAND_DISPLAY` to reach niri. Some tmux panes lose it (and
`DISPLAY`); in those, `code .` exits 0 and opens no window, with no error. Check with
`echo $WAYLAND_DISPLAY`. Fix the pane with:

```bash
export WAYLAND_DISPLAY=wayland-1 DISPLAY=:0
```

or open a new pane. The window usually did not fail to open elsewhere; `niri msg windows` shows
what exists. Cause not yet found: tmux's `update-environment` already lists both variables.
