-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- -- Глушим стрелки во всех основных режимах (Normal, Insert, Visual)
local modes = { "n", "i", "v", "x" }
local arrows = { "<Up>", "<Down>", "<Left>", "<Right>" }

for _, mode in ipairs(modes) do
  for _, arrow in ipairs(arrows) do
    vim.keymap.set(mode, arrow, "<Nop>", { noremap = true, silent = true })
  end
end
