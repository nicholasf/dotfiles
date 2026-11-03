-- Put pop-up boxes at the bottom of the screen.
return {
  -- Key hints (Space, g, ...) as a full-width strip along the bottom.
  {
    "folke/which-key.nvim",
    opts = { preset = "classic" },
  },
  -- Neovim's own : command line, on its own line under the status bar, so the
  -- status bar keeps showing the mode (COMMAND). cmdheight is set in
  -- lua/config/options.lua.
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
    },
  },
  -- File and search pickers as a panel along the bottom.
  {
    "folke/snacks.nvim",
    opts = {
      picker = { layout = { preset = "ivy" } },
    },
  },
}
