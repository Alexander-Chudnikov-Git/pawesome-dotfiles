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

        -- Get the current tabpage
        local current_tabpage = vim.fn.tabpagenr()

        -- Get the list of windows in the current tabpage
        local windows = vim.fn.gettabinfo(current_tabpage)[1].windows

        -- Iterate over the windows and print their IDs
        for _, winid in ipairs(windows) do
            print( "Window ID: " .. winid )
            vim.api.nvim_win_set_option(winid, 'scrolloff', 999)
            vim.api.nvim_win_set_option(winid, 'sidescrolloff', 999)
        end
    end)
end

-- Handle widnow resize events
function resize_window_handler()
    simulate_ctrl_f()
    simulate_ctrl_b()

    -- Get the current tabpage
    local current_tabpage = vim.fn.tabpagenr()

    -- Get the list of windows in the current tabpage
    local windows = vim.fn.gettabinfo(current_tabpage)[1].windows

    -- Iterate over the windows and print their IDs
    for _, winid in ipairs(windows) do
        print( "Window ID: " .. winid )
        
        if winid ~= 1000 then
            vim.api.nvim_win_close(win_id, true)
        end
    end
end

-- Attach the resize_window_handler function to VimResized autocmd event
vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
        resize_window_handler()
    end
})

-- Attach the create_window_handler() function to Vim start event
vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
        create_window_handler()
    end
})