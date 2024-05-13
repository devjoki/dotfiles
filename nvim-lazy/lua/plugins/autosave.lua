return {
  --{
  --  "pocco81/auto-save.nvim",
  --  config = function()
  --    require("auto-save").setup({
  --      write_all_buffers = true,
  --      execution_message = {
  --        message = function(bufnr)
  --          return ""
  --        end,
  --        dim = 0.18, -- dim the color of `message`
  --        cleaning_interval = 5000, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
  --      },
  --      trigger_events = { "CursorHold" },
  --    })
  --  end,
  --},
}
