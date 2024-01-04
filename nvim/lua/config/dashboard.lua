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

local dashboard = require("dashboard")

local conf = {}
conf.header = {}

conf.center = {
    {
        icon = "󰱽  ",
        desc = "Find File              ",
        action = "Telescope file_browser",
        key = "f",
    },
    {
        icon = "󰻭  ",
        desc = "New file               ",
        action = "tabnew $MYVIMRC | enew",
        key = "n",
    },
    {
        icon = "󱁼  ",
        desc = "Open Lazy config       ",
        action = "Lazy",
        key = "l",
    },
    {
        icon = "󱀫  ",
        desc = "Open Nvim config       ",
        action = "tabnew $MYVIMRC | tcd %:p:h",
        key = "c",
    }, 
    {
        icon = "󰗼  ",
        desc = "Quit Nvim              ",
        action = "qa",
        key = "q",
    },
}

function dashboard_redraw()
    -- Redraw the dashboard on window resize
    dashboard.setup({
        theme = 'doom',
        shortcut_type = 'number',
        config = conf,
        preview = {
            command = "cat | bash ~/.config/nvim/scripts/ansi-print.sh",
            file_path = "~/.config/nvim/data/art/fox_2.ansi",
            file_height = 12,
            file_width = 44,
        },
    })
end

dashboard_redraw()
