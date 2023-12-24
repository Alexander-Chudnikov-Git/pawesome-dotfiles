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

vim.o.guifont = "RobotoMono Nerd Font Propo:h10"

-- Enable termguicolors for ANSI support
vim.o.termguicolors = true

-- Set t_8f and t_8b for true color support
vim.api.nvim_exec([[
  if &term =~ 'truecolor' || has('gui_running')
    " Use true colors in the terminal
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
]], false)


if vim.g.neovide then
    vim.opt.linespace          = 0
    vim.g.neovide_scale_factor = 1.0

    -- Border offset 
    vim.g.neovide_padding_top    = 8
    vim.g.neovide_padding_bottom = 8
    vim.g.neovide_padding_right  = 0
    vim.g.neovide_padding_left   = 8

    --- Helper function for transparency formatting
    local alpha = function()
      return string.format("%x", math.floor(255 * vim.g.neovide_transparency_point or 0.8))
    end

    -- Set transparency and background color (title bar color)
    vim.g.neovide_transparency = 0.0
    vim.g.neovide_transparency_point = 0.8
    vim.g.neovide_background_color = "#0B0A09" .. alpha()

    -- Add keybinds to change transparency
    local change_transparency = function(delta)
      vim.g.neovide_transparency_point = vim.g.neovide_transparency_point + delta
      vim.g.neovide_background_color = "#0B0A09" .. alpha()
    end

    vim.keymap.set({ "n", "v", "o" }, "<C-]>", function()
      change_transparency(0.01)
    end)

    vim.keymap.set({ "n", "v", "o" }, "<C-[>", function()
      change_transparency(-0.01)
    end)

    vim.g.neovide_floating_blur_amount_x = 4.0
    vim.g.neovide_floating_blur_amount_y = 4.0
    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 10
    vim.g.neovide_light_angle_degrees = 45
    vim.g.neovide_light_radius = 5

    vim.g.neovide_scroll_animation_length    = 0
    vim.g.neovide_scroll_animation_far_lines = 0

    vim.g.neovide_hide_mouse_when_typing = false
    vim.g.neovide_underline_stroke_scale = 1.0

    vim.g.neovide_refresh_rate      = 60
    vim.g.neovide_refresh_rate_idle = 10

    vim.g.neovide_no_idle      = true
    vim.g.neovide_confirm_quit = true

    vim.g.neovide_fullscreen = false
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_profiler = false

    vim.g.neovide_cursor_animation_length  = 0.1
    vim.g.neovide_cursor_trail_size        = 0.1
    
    vim.g.neovide_cursor_antialiasing           = true
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_animate_command_line   = true

    vim.g.neovide_cursor_vfx_mode = ""
    vim.g.neovide_cursor_vfx_mode = ""

    vim.g.neovide_cursor_vfx_opacity = 200.0

    vim.g.neovide_cursor_vfx_particle_lifetime = 1
    vim.g.neovide_cursor_vfx_particle_density  = 7.0
    vim.g.neovide_cursor_vfx_particle_speed    = 10.0
    vim.g.neovide_cursor_vfx_particle_phase    = 1.5
    vim.g.neovide_cursor_vfx_particle_curl     = 1.0

end