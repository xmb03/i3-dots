return {
  {
    "RedsXDD/neopywal.nvim",
    name = "neopywal",
    lazy = false,
    priority = 1000,
    config = function()
      local neopywal = require("neopywal")

      neopywal.setup({
        transparent_background = true, -- Включаем прозрачность под Hyprland
      })

      -- Принудительно выставляем цветовую схему после её настройки
      vim.cmd.colorscheme("neopywal")
    end,
  },
}
