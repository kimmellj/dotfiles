return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(lang)
        return lang ~= "jsonc"
      end, opts.ensure_installed or {})
    end,
    init = function()
      vim.treesitter.language.register("json", "jsonc")
    end,
  },
}
