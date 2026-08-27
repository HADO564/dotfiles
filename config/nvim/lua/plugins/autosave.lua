return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      debounce_delay = 2000, -- save 2 seconds after you stop typing
      condition = function(buf)
        local fn = vim.fn
        -- don't save special/unnamed buffers
        if fn.getbufvar(buf, "&modifiable") == 0 then return false end
        if fn.empty(fn.bufname(buf)) == 1 then return false end
        return true
      end,
    },
  },
}
