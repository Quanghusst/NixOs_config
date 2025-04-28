{ config, pkgs, ... }:
let
  user = builtins.getEnv "USER";
in
{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.11"; 
  programs.home-manager.enable = true;
	## PACKAGES
	home.packages = with pkgs; [
		neovim
		git
		(nerdfonts.override { fonts = [ "FiraCode" ]; })
		gcc
  		gnumake # make nếu cần biên dịch
		brave
		octaveFull
		wezterm # terminal 
		wl-clipboard # Copy paste for nvim
		python39
		fastfetch
		starship
		tmux
		fzf
		gh
		## TU TAO SCRIPT my-hello  IN RA HELLO QUANG
		(writeShellScriptBin "my-hello" ''
		echo "Hello, ${config.home.username}!"
		'')

	];

	## FILE
	home.file = {
	############################# 	CONFIG NVIM   ####################
	".config/nvim/init.lua".text = ''
	-- COLORS SET
	colors = {
	  gray       = '#44475a',
	  lightgray  = '#5f6a8e',
	  orange     = '#ffb86c',
	  purple     = '#bd93f9',
	  red        = '#ff5555',
	  yellow     = '#f1fa8c',
	  green      = '#50fa7b',
	  white      = '#f8f8f2',
	  black      = '#282a36',
	}
	-- Khởi tạo Lazy
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
	  vim.fn.system({
	    "git",
	    "clone",
	    "--filter=blob:none",
	    "https://github.com/folke/lazy.nvim.git",
	    "--branch=stable", -- latest stable release
	    lazypath,
	  })
	end
	vim.opt.rtp:prepend(lazypath)

	-- Cấu hình plugin với lazy
	require("lazy").setup({
	    -- Cài đặt nvim-tree và các dependencies
	    {
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
		"nvim-tree/nvim-web-devicons",
		},
		config = function()
		-- Cấu hình nvim-tree cơ bản
		require("nvim-tree").setup {
		    sort_by = "case_sensitive",
		    view = {
		    adaptive_size = true,
		    },
		    renderer = {
		    group_empty = true,
		    },
		}
		end,
	    },
	    -- NVIM TREESITTER
	    {
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
		require('nvim-treesitter.configs').setup({
		    ensure_installed = { 'lua', 'vim', 'javascript', 'typescript', 'html', 'css', 'markdown'}, -- Các ngôn ngữ bạn muốn cài
		    highlight = { enable = true },
		    indent = { enable = true },
		    -- enable folding (requires 'foldexpr')
		    fold = { enable = true },
		})
		end,
	    },
	    -- STATUS LINE 
	    {
		'nvim-lualine/lualine.nvim',
		config = function()
		require('lualine').setup({
		    options = {
			-- Available themes in C:\Users\ledan\AppData\Local\nvim-data\lazy\lualine.nvim\lua\lualine\themes
			theme = 'dracula'
		    }
		})
		end
	    },
	    -- TAB LINE
	    {
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons',
		config = function()
		require("bufferline").setup{
		    options = {
			-- mode = "tabs", -- or "buffers"
			separator_style = "slant", -- or "thick", "thin", { 'any', 'any' },
			indicator_style = 'underline', -- or 'none', 'icon', 'line'
			-- buffer_close_icon = '',
			modified_icon = '●',
			-- close_icon = '',
			left_trunc_marker = '',
			right_trunc_marker = '',
			max_name_length = 14,
			max_prefix_length = 13,
			tab_size = 13,
			-- ... các tùy chọn khác
		    },
		
		}
		end
	    },
	    -- FLOAT TERMINAL 
	    {
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
		    require("toggleterm").setup()
		end
	    },
	})


	vim.g.mapleader = " " -- Đặt leader key là phím Space
	vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle nvim-tree',  silent = true  })
	vim.keymap.set('n', '<leader>t', ':ToggleTerm<CR>', { desc = 'Toggle terminal',  silent = true  })
	vim.opt.number = true 

	-- TRANSPARENT VIM --
	vim.cmd [[
	  highlight Normal guibg=none ctermbg=none
	  highlight NormalNC guibg=none ctermbg=none
	  highlight SignColumn guibg=none ctermbg=none
	  highlight LineNr guibg=none ctermbg=none
	  highlight CursorLine guibg=none ctermbg=none
	  highlight CursorLineNr guibg=none ctermbg=none
	]]


	-- Tắt màn khởi động 
	vim.opt.shortmess:append "I"
	-- Xóa dấu ~ bên lề trái 
	vim.opt.fillchars:append({ eob = " " })
	-- Bật số dòng tương đối cho
	vim.opt.relativenumber = true 
	-- Normal mode: p -> paste từ clipboard
	vim.keymap.set('n', 'p', '"+p', { noremap = true, silent = true })
	-- Visual mode: p -> paste từ clipboard
	vim.keymap.set('v', 'p', '"+p', { noremap = true, silent = true })
	-- Norman mode: y -> copy to clipboard
	vim.keymap.set('v', 'y', '"+y', { noremap = true, silent = true })
	'';
		
        ############################# 	CONFIG WEZTERM    ###########################
	".config/wezterm/wezterm.lua".text = ''
 local wezterm = require("wezterm")
		local config = wezterm.config_builder()
		local io = require("io")
		local os = require("os")
		local brightness = 0.03

		-- image setting
		local user_home = os.getenv("HOME")
		local background_folder = user_home .. "/Pictures/ryo-yamada"
		local function pick_random_background(folder)
		    local handle = io.popen('ls "' .. folder .. '"')
		    if handle ~= nil then
			local files = handle:read("*a")
			handle:close()

			local images = {}
			for file in string.gmatch(files, "[^\n]+") do
			    table.insert(images, file)
			end

			if #images > 0 then
			    return folder .. "/" .. images[math.random(#images)]
			else
			    return nil
			end
		    end
		end

		config.window_background_image_hsb = {
		    -- Darken the background image by reducing it
			    brightness = brightness,
			    hue = 1.0,
			    saturation = 0.8,
			}

			-- default background
			local bg_image = user_home .. "/.config/nvim/bg/bg.jpg"

			config.window_background_image = bg_image
			-- end image setting

			-- window setting
			config.window_background_opacity = 0.90
			-- config.macos_window_background_blur = 85
			config.window_padding = {
			    left = 2,
			    right = 2,
			    top = 2,
			    bottom = 2,
			}

			config.color_scheme = "Tokyo Night"
			config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium", stretch = "Expanded" })
			config.font_size = 16 

			config.window_decorations = "NONE"
			config.enable_tab_bar = false
			config.hide_tab_bar_if_only_one_tab = true
		-- keys
		config.keys = {
		    {
			key = "b",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window)
			    bg_image = pick_random_background(background_folder)
			    if bg_image then
				window:set_config_overrides({
				    window_background_image = bg_image,
				})
				wezterm.log_info("New bg:" .. bg_image)
			    else
				wezterm.log_error("Could not find bg image")
			    end
			end),
		    },
		    {
			key = "L",
			mods = "CTRL|SHIFT",
			action = wezterm.action.OpenLinkAtMouseCursor,
		    },
		    {
			key = ">",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window)
			    brightness = math.min(brightness + 0.01, 1.0)
			    window:set_config_overrides({
				window_background_image_hsb = {
				    brightness = brightness,
				    hue = 1.0,
				    saturation = 0.8,
				},
				window_background_image = bg_image
			    })
			end),
		    },
		    {
			key = "<",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window)
			    brightness = math.max(brightness - 0.01, 0.01)
			    window:set_config_overrides({
				window_background_image_hsb = {
				    brightness = brightness,
				    hue = 1.0,
				    saturation = 0.8,
				},
				window_background_image = bg_image
			    })
			end),
		    },
		}

		-- others
		config.default_cursor_style = "BlinkingUnderline"
		config.cursor_thickness = 2
		return config

      	'';

	};

	home.sessionVariables = { 
	  EDITOR = "nvim";
	  VISUAL = "nvim";
	  GIT_EDITOR = "nvim";
	  PAGER = "bat";
	  BROWSER = "brave";
	};
	############################# 	CONFIG GIT   ###########################
	programs.git = {
	enable = true;

		userName = "Quanghusst";   # Tên của bạn
		userEmail = "quang.ld224113@sis.hust.edu.vn"; # Email của bạn

		extraConfig = {
			init.defaultBranch = "main";
			core.editor = "nvim";
			pull.rebase = true;
			color.ui = "auto";
		};
	};
	################################### STARSHIP CONFIG (like oh my posh) #####################
	programs.bash = {
	  enable = true;
	};
	programs.starship = {
	  enable = true;
	  settings = {
	    add_newline = false;
	    character = {
	      success_symbol = "[➜](bold green)";
	      error_symbol = "[✗](bold red)";
	    };
	    git_branch = {
	      symbol = "🌱 ";
	    };
	  };
	};
	################################### TMUX CONFIG ####################################
	programs.tmux = {
	    enable = true;
	    clock24 = true;    # Hiển thị đồng hồ 24h trên thanh trạng thái
	    terminal = "screen-256color";  # Giúp màu sắc chuẩn hơn
	    extraConfig = ''
	      set -g mouse on  # Bật mouse support: click chọn pane
	      set-option -g history-limit 10000  # Lưu nhiều dòng lịch sử hơn
	    '';
	};
}
