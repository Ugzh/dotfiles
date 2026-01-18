return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "thin",
    },
    highlights = {
      fill = {
        bg = 'none' 
      },
      background = {
        bg = 'none' 
      },
      buffer_selected = {
        bg = 'none', 
        bold = true,
        italic = false, 
      },
      separator = {
        fg = 'none',
        bg = 'none'
      },
      separator_selected = {
        fg = 'none',
        bg = 'none'
      },
      modified_selected = {
        bg = 'none'
      },
      duplicate_selected = {
        bg = 'none'
      },
      indicator_selected = {
          bg = 'none'
      },
      close_button = {
      bg = "none",
      },
      close_button_selected = {
        bg = "none",
      },
    }
  },
}
