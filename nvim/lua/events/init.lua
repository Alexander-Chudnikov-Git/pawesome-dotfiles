--
-- ╔════════════════════════════════════════════════════════════════════════════════════════════╗
-- ║                                                                                            ║
-- ║   .S_sSSs     .S_SSSs     .S     S.     sSSs    sSSs    sSSs_sSSs     .S_SsS_S.     sSSs   ║
-- ║  .SS~YS%%b   .SS~SSSSS   .SS     SS.   d%%SP   d%%SP   d%%SP~YS%%b   .SS~S*S~SS.   d%%SP   ║
-- ║  S%S   `S%b  S%S   SSSS  S%S     S%S  d%S'    d%S'    d%S'     `S%b  S%S `Y' S%S  d%S'     ║
-- ║  S%S    S%S  S%S    S%S  S%S     S%S  S%S     S%|     S%S       S%S  S%S     S%S  S%S      ║
-- ║  S%S    d*S  S%S SSSS%S  S%S     S%S  S&S     S&S     S&S       S&S  S%S     S%S  S&S      ║
-- ║  S&S   .S*S  S&S  SSS%S  S&S     S&S  S&S_Ss  Y&Ss    S&S       S&S  S&S     S&S  S&S_Ss   ║
-- ║  S&S_sdSSS   S&S    S&S  S&S     S&S  S&S~SP  `S&&S   S&S       S&S  S&S     S&S  S&S~SP   ║
-- ║  S&S~YSSY    S&S    S&S  S&S     S&S  S&S       `S*S  S&S       S&S  S&S     S&S  S&S      ║
-- ║  S*S         S*S    S&S  S*S     S*S  S*b        l*S  S*b       d*S  S*S     S*S  S*b      ║
-- ║  S*S         S*S    S*S  S*S  .  S*S  S*S.      .S*P  S*S.     .S*S  S*S     S*S  S*S.     ║
-- ║  S*S         S*S    S*S  S*S_sSs_S*S   SSSbs  sSS*S    SSSbs_sdSSS   S*S     S*S   SSSbs   ║
-- ║  S*S         SSS    S*S  SSS~SSS~S*S    YSSP  YSS'      YSSP~YSSY    SSS     S*S    YSSP   ║
-- ║  SP                 SP                                                       SP            ║
-- ║  Y    ARCH THEME    Y     MADE BY CHOOI    admin@redline-software.moscow     Y             ║
-- ║                                                                                            ║
-- ╚════════════════════════════════════════════════════════════════════════════════════════════╝
--

-- Create a function to simulate keypress
local function feedkeys(keys, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, true)
end

-- Simulate Ctrl + B press
function simulate_ctrl_b()
    feedkeys("<C-b>", "n") -- Press Ctrl + B in normal mode
end

-- Simulate Ctrl + B press
function simulate_ctrl_f()
    feedkeys("<C-f>", "n") -- Press Ctrl + B in normal mode
end

-- Handle widnow create event
function create_window_handler()
    vim.fn.timer_start(200, function()
        simulate_ctrl_f()
        simulate_ctrl_b()
    end)
end

-- Handle widnow resize events
function resize_window_handler()
    dashboard_redraw()
    simulate_ctrl_f()
    simulate_ctrl_b()
end

-- Attach the resize_window_handler function to VimResized autocmd event
vim.api.nvim_exec([[
    augroup ResizeWindow
        autocmd!
        autocmd VimResized * lua resize_window_handler()
    augroup END
]], false)

-- Attach the create_window_handler() function to Vim start event
vim.api.nvim_exec([[
    autocmd VimEnter * lua create_window_handler()
]], false)
