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
		cargo # De tai Mason cho nix 
		## TU TAO SCRIPT my-hello  IN RA HELLO QUANG
		(writeShellScriptBin "my-hello" ''
		echo "Hello, ${config.home.username}!"
		'')

	];

	## FILE
	home.file = {

	############################# 	CONFIG TMUX ###############################################
	".tmux.conf".text = '' 
    # Dùng Ctrl + Shift + V để tách pane dọc
    bind -n C-V split-window -v

    # Dùng Ctrl + l để chọn pane bên trái
    bind -n C-l select-pane -L

    # Dùng Ctrl + h để chọn pane bên phải
    bind -n C-h select-pane -R
    '';

	############################# 	CONFIG NVIM   ###############################################
	".config/nvim/init.lua".text = '' 
	-- pull lazy vim
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
	
	-- install plugins and options
	require("vim-options")
	require("vim-helpers")
	require("help-floating")
	require("floating-term")
	require("lazy").setup("plugins")
	require("snipets") -- Luasnip should be installed first, so this file is here
'';


".config/nvim/instructions.md".text = '' 

| Phím tắt                   | Chức năng                                                                 |
|----------------------------|--------------------------------------------------------------------------|
| `Space + t`                | Mở/tắt terminal                                                          |
| `gcc`                      | Comment 1 dòng                                                           |
| `gc`                       | Comment 1 khối                                                           |
| `Ctrl + Space`             | Mở menu gợi ý (❌ không hoạt động)                                      |
| `Ctrl + e`                 | Đóng menu autocomplete                                                   |
| `Ctrl + j`                 | Di chuyển xuống danh sách gợi ý                                          |
| `Ctrl + k`                 | Di chuyển lên danh sách gợi ý                                            |
| `Ctrl + b` / `Ctrl + f`    | Cuộn lên xuống |
| `K`                        | Hover hiển thị thông tin hàm, biến dưới con trỏ                         |
| `gd`                       | Nhảy đến hàm đã được khai báo (Go to definition)                        |
| `gD`                       | Nhảy đến declaration                                                     |
| `gi`                       | Nhảy đến implementation                                                  |
| `gr`                       | Tìm tất cả nơi tham chiếu                                                |
| `Space + rn`               | Đổi tên tất cả tên biến/hàm trong dự án (Rename)                        |
| `Space + ca`               | Gợi ý sửa lỗi (Code action) (❌ không hoạt động)                         |
| `Space + e`                | Hover lỗi, thông tin biến, hàm dưới con trỏ                              |
| `Space + fm`               | Hiển thị danh sách hàm theo filetype (dùng telescope)                   |
| `Space + gf`               | Format file hiện tại                                                     |
| `:TimerStart`              | Bắt đầu 1 chu kỳ Pomodoro                                                |
| `:TimerRepeat`             | Lặp lại chu kỳ Pomodoro                                                  |
| `:TimerSessionpomo`        | Chạy Pomodoro đã định nghĩa                                              |
| `Visual mode + Space + s` | Bọc từ đã chọn, ví dụ `(quang)`                                          |
| `Space + ff`               | Tìm file trong thư mục hiện tại                                          |
| `Space + pf`               | Tìm file được git quản lý                                                |
| `Space + fb`               | Liệt kê tất cả buffer đang mở                                            |
| `Space + fh`               | Tìm help tag                                                             |
| `Space + u`                | Bật/tắt undo tree (⚠️ lỗi)                                               |
| `Space + uf`               | Focus vào undo tree (❌ không hoạt động)                                 |
        '';
".config/nvim/lua/floating-term.lua".text = '' 
	local state = { floating = { buf = -1, win = -1 } }
	local function create_floating_window(opts)
	    opts = opts or {}
	    local width = math.floor(vim.o.columns * 0.8)
	    local height = math.floor(vim.o.lines * 0.8)
	
	    local row = math.floor((vim.o.lines - height) / 2)
	    local col = math.floor((vim.o.columns - width) / 2)
	
	    local buf = nil
	    if vim.api.nvim_buf_is_valid(opts.buf) then
	        buf = opts.buf
	    else
	        buf = vim.api.nvim_create_buf(false, true)
	    end
	
	    local config = {
	        relative = "editor",
	        width = width,
	        height = height,
	        row = row,
	        col = col,
	        style = "minimal",
	        border = "rounded"
	    }
	    vim.api.nvim_set_hl(0, "MyFloatingWindow", { bg = "#1e1e1e", fg = "#ffffff", blend = 10 })
	    local win = vim.api.nvim_open_win(buf, true, config)
	    return { buf = buf, win = win }
	end
	
	local toggle_term = function()
	    if not vim.api.nvim_win_is_valid(state.floating.win) then
	        state.floating = create_floating_window { buf = state.floating.buf }
	        if vim.bo[state.floating.buf].buftype ~= "terminal" then
	            vim.cmd.terminal()
	        end
	    else
	        vim.api.nvim_win_hide(state.floating.win)
	    end
	end
	
	vim.api.nvim_create_user_command("FTerm", toggle_term, {})
	vim.keymap.set({ "n", "t" }, "<leader>t", toggle_term)
'';

".config/nvim/lua/help-floating.lua".text = '' 
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "help",
		callback = function()
	        local crbuf = vim.api.nvim_get_current_buf()
	        vim.cmd("wincmd c")
			-- vim.cmd("wincmd L")
			vim.api.nvim_open_win(crbuf, true, {
				relative = "editor",
				width = math.floor(vim.o.columns * 0.8),
				height = math.floor(vim.o.lines * 0.8),
				col = math.floor(vim.o.columns * 0.1),
				row = math.floor(vim.o.lines * 0.1),
				border = "rounded",
			})
		end,
	})
'';

".config/nvim/lua/snipets.lua".text = '' 
	local ls = require("luasnip")
	local s = ls.snippet
	local t = ls.text_node
	
	ls.add_snippets("go", {
		s("ifer", {
			t({
				"if err != nil {",
				'\tlog.Error("something")',
				"}",
			}),
		}),
		s("iferr", {
			t({
				"if err != nil {",
				'\tlog.Error("something")',
				"\treturn err",
				"}",
			}),
		}),
	})
'';

".config/nvim/lua/vim-helpers.lua".text = '' 
	-- all vim helper functions here
	
	vim.keymap.set("n", "<leader>ce", function()
		local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
		if #diagnostics > 0 then
			local message = diagnostics[1].message
			vim.fn.setreg("+", message)
			print("Copied diagnostic: " .. message)
		else
			print("No diagnostic at cursor")
		end
	end, { noremap = true, silent = true })
	
	-- go to errors in a file :/
	vim.keymap.set("n", "<leader>ne", vim.diagnostic.goto_next) -- next err
	vim.keymap.set("n", "<leader>pe", vim.diagnostic.goto_prev) -- previous err
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
	-- copy current file path (absolute) into clipboard
	vim.keymap.set("n", "<leader>cp", function()
		local filepath = vim.fn.expand("%:p")
		vim.fn.setreg("+", filepath) -- Copy to Neovim clipboard
		vim.fn.system("echo '" .. filepath .. "' | pbcopy") -- Copy to macOS clipboard
		print("Copied: " .. filepath)
	end, { desc = "Copy absolute path to clipboard" })
	
	-- open the current file in browser
	vim.keymap.set("n", "<leader>ob", function()
	  local file_path = vim.fn.expand("%:p")
	  if file_path == "" then
	    print("No file to open")
	    return
	  end

	  local cmd = nil
	  if vim.fn.has("mac") == 1 then
	    cmd = "open -a 'Brave Browser' " .. file_path
	  else
	    -- Sử dụng lệnh `brave` vì bạn đã xác nhận nó tồn tại
	    cmd = "brave " .. file_path
	  end

	  os.execute(cmd .. " &")
	end, { desc = "Open current file in Brave browser" })

'';

".config/nvim/lua/vim-options.lua".text = '' 
	vim.cmd("set expandtab")
	vim.cmd("set tabstop=4")
	vim.cmd("set softtabstop=4")
	vim.cmd("set shiftwidth=4")
	vim.g.mapleader = " "
	vim.cmd("set number")
	vim.cmd("set relativenumber")
	vim.cmd("set cursorline")
	vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "white" })
	vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#ead84e" })
	vim.api.nvim_set_option("clipboard", "unnamed")
	vim.opt.hlsearch = true
	vim.opt.incsearch = true
	-- move selected lines
	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
	-- paste over highlight word
	vim.keymap.set("x", "<leader>p", '"_dP')
	vim.opt.colorcolumn = "94"
	-- F1 cheatsheet
	vim.keymap.set('n', '<F1>', function()
	  vim.cmd('view ~/.config/nvim/instructions.md')
	end, { noremap = true, silent = true })
	-- fk llm-ls
	local notify_original = vim.notify
	vim.notify = function(msg, ...)
		if
			msg
			and (
				msg:match("position_encoding param is required")
				or msg:match("Defaulting to position encoding of the first client")
				or msg:match("multiple different client offset_encodings")
			)
		then
			return
		end
		return notify_original(msg, ...)
	end
	-- Tắt màn khởi động 
	vim.opt.shortmess:append "I"
	
	-- Xóa dấu ~ bên lề trái 
	vim.opt.fillchars:append({ eob = " " })
'';

".config/nvim/lua/plugins/arrow.lua".text = '' 
	return {
		"otavioschwanck/arrow.nvim",
		opts = {
			show_icons = true,
			leader_key = "\t", -- Recommended to be a single key
			buffer_leader_key = "m", -- Per Buffer Mappings
		},
	}
'';

".config/nvim/lua/plugins/auto-tag.lua".text = '' 
	return {
		"windwp/nvim-ts-autotag",
		opts = {
			-- Defaults
			enable_close = true, -- Auto close tags
			enable_rename = true, -- Auto rename pairs of tags
			enable_close_on_slash = false, -- Auto close on trailing </
		},
		-- Also override individual filetype configs, these take priority.
		-- Empty by default, useful if one of the "opts" global settings
		-- doesn't work well in a specific filetype
		config = function()
			require("nvim-ts-autotag").setup()
			per_filetype = {
				["html"] = {
					enable_close = false,
				},
			}
		end,
	}
'';

".config/nvim/lua/plugins/comment.lua".text = '' 
	return {
		"numToStr/Comment.nvim",
		opts = {},
	}
'';

".config/nvim/lua/plugins/completions.lua".text = '' 
	return {
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
		},
		{
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		{
			"hrsh7th/nvim-cmp",
			config = function()
				local cmp = require("cmp")
				require("luasnip.loaders.from_vscode").lazy_load()
	
				cmp.setup({
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
						end,
					},
					window = {
						completion = cmp.config.window.bordered(),
						documentation = cmp.config.window.bordered(),
					},
					mapping = cmp.mapping.preset.insert({
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
						["<C-k>"] = cmp.mapping.select_prev_item(),
						["<C-j>"] = cmp.mapping.select_next_item(),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "zls" },
						{ name = "buffer" },
						{ name = "path" },
						{ name = "pylsp" },
						{ name = "gci" },
						{ name = "ts_ls" },
						{ name = "gopls" },
						{ name = "nix" },
						{ name = "buf_ls" },
						{ name = "render-markdown" },
					}),
				})
			end,
		},
	}
'';

".config/nvim/lua/plugins/debugging.lua".text = '' 
	return {
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "leoluz/nvim-dap-go" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			require("dap-go").setup()
			require("dapui").setup()
	
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
			vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
			vim.keymap.set("n", "<Leader>dc", dap.continue, {})
		end,
	}
	
	-- dont for get to install debugger here: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
	-- eg: go... brew install delve, then add go dependencies
'';

".config/nvim/lua/plugins/lsp-configs.lua".text = '' 
	return {
		{
			"williamboman/mason.nvim",
			-- NOTE: comment it to install jdtls (java language server)
			config = function()
				require("mason").setup()
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			lazy = false,
			opts = {
				auto_install = true,
			},
			config = function()
				require("mason-lspconfig").setup({
					-- manually install packages that do not exist in this list please
					--ensure_installed = { "lua_ls", "matlab_ls", "pyright", "zls", "gopls", "ts_ls" },
				})
			end,
		},
		{
			"neovim/nvim-lspconfig",
			lazy = false,
			config = function()
				local capabilities = require("cmp_nvim_lsp").default_capabilities()
				local lspconfig = require("lspconfig")
				-- lua
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							telemetry = {
								enable = false,
							},
						},
					},
				})
				-- typescript
				-- lspconfig.ts_ls.setup({
				-- 	capabilities = capabilities,
				-- })
				-- Js
				-- lspconfig.eslint.setup({
				-- 	capabilities = capabilities,
				-- })
				-- matlab
				-- lspconfig.matlab_ls.setup({
				-- 	capabilities = capabilities,
				-- })
				-- zig
				--lspconfig.zls.setup({
					-- capabilities = capabilities,
				-- })
				-- yaml
				lspconfig.yamlls.setup({
					capabilities = capabilities,
				})
				-- tailwindcss
				-- lspconfig.tailwindcss.setup({
				-- 	capabilities = capabilities,
				-- })
				-- golang
				-- lspconfig.gopls.setup({
				-- 	capabilities = capabilities,
				-- })
				lspconfig.pyright.setup({ capabilities = capabilities })
				--java
				-- lspconfig.jdtls.setup({
				-- 	settings = {
				-- 		java = {
				-- 			configuration = {
				-- 				runtimes = {
				-- 					{
				-- 						name = "JavaSE-23",
				-- 						path = "/opt/jdk-23",
				-- 						default = true,
				-- 					},
				-- 				},
				-- 			},
				-- 		},
				-- 	},
				-- })
				-- nix
				lspconfig.rnix.setup({ capabilities = capabilities })
				-- protocol buffer
				lspconfig.buf_ls.setup({ capabilities = capabilities })
				vim.api.nvim_create_autocmd("FileType", {
					pattern = "proto",
					callback = function()
						lspconfig.buf_language_server.setup({
							capabilities = capabilities,
						})
					end,
				})
	
				-- lsp kepmap setting
				vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
				vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
				-- list all methods in a file
				-- working with go confirmed, don't know about other, keep changing as necessary
				vim.keymap.set("n", "<leader>fm", function()
					local filetype = vim.bo.filetype
					local symbols_map = {
						python = "function",
						javascript = "function",
						typescript = "function",
						java = "class",
						lua = "function",
						go = { "method", "struct", "interface" },
					}
					local symbols = symbols_map[filetype] or "function"
					require("telescope.builtin").lsp_document_symbols({ symbols = symbols })
				end, {})
			end,
		},
	}
'';

".config/nvim/lua/plugins/lualine.lua".text = '' 
	return {
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "OceanicNext",
				},
			})
		end,
	}
'';

".config/nvim/lua/plugins/md.lua".text = '' 
	return {
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {},
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	}
'';

".config/nvim/lua/plugins/neo-tree.lua".text = '' 
	return {
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			-- key map for neo tree
			vim.keymap.set("n", "<leader>v", ":Neotree filesystem reveal right<CR>", {silent = true})
			vim.keymap.set("n", "<leader>xx", ":Neotree filesystem close <CR>", {silent = true})
		end,
	}
'';

".config/nvim/lua/plugins/none-ls.lua".text = '' 
	return {
	    "nvimtools/none-ls.nvim",
	    config = function()
	        local null_ls = require("null-ls")
	        null_ls.setup({
	            sources = {
	                null_ls.builtins.formatting.stylua,
	                null_ls.builtins.formatting.prettier,
	                null_ls.builtins.formatting.black,
	                null_ls.builtins.formatting.isort,
	                -- null_ls.builtins.diagnostics.mypy,
	                -- null_ls.builtins.diagnostics.ruff,
	                null_ls.builtins.formatting.gofumpt,
	                null_ls.builtins.code_actions.impl,
	            },
	        })
	        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	    end,
	}
'';

".config/nvim/lua/plugins/pomo.lua".text = '' 
	return {
		"epwalsh/pomo.nvim",
		version = "*",
		lazy = true,
		cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
	
		dependencies = {
			-- Optional, but highly recommended if you want to use the "Default" timer
			"rcarriga/nvim-notify",
			config = function()
				local play_sound = function()
					local home_dir = os.getenv("HOME")
					local sound_path = home_dir .. "/.config/nvim/break.mp3"
					vim.loop.spawn("afplay", {
						args = { sound_path },
						detached = true,
					}, function()
						print("Sound finished playing")
					end)
	
					vim.defer_fn(function()
						vim.fn.system("pkill afplay")
						print("Sound stopped after 15 seconds")
					end, 15000)
				end
				require("notify").setup({
					background_colour = "#1e1e2e",
					on_open = function(notification)
						if notification then
							play_sound()
						end
					end,
				})
				require("lualine").setup({
					sections = {
						lualine_x = {
							function()
								local ok, pomo = pcall(require, "pomo")
								if not ok then
									return ""
								end
	
								local timer = pomo.get_first_to_finish()
								if timer == nil then
									return ""
								end
	
								return "󰄉 " .. tostring(timer)
							end,
							"encoding",
							"fileformat",
							"filetype",
						},
					},
				})
			end,
		},
		opts = {
			work_time = 25,
			break_time = 5,
			long_break_time = 15,
			notifier = {
				sticky = true,
			},
			sessions = {
				pomodoro = {
					{ name = "Work", duration = "30m" },
					{ name = "Short Break", duration = "7m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "7m" },
					{ name = "Work", duration = "25m" },
					{ name = "Long Break", duration = "10m" },
				},
			},
		},
	}
'';

".config/nvim/lua/plugins/surround.lua".text = '' 
	return {
		"kunkka19xx/simple-surr",
		config = function()
			require("simple-surr").setup({
				keymaps = {
					surround_selection = "<leader>s", -- Keymap for surrounding selection
					surround_word = "<leader>sw", -- Keymap for surrounding word
					remove_or_change_surround_word = "<leader>sr", -- Keymap for removing/changing surrounding word
					toggle_or_change_surround_selection = "<leader>ts", -- Keymap for removing/changing surrounding selected text
				},
			})
		end,
	}
'';

".config/nvim/lua/plugins/telescope.lua".text = '' 
	return {
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			-- or                              , branch = '0.1.x',
			dependencies = { "nvim-lua/plenary.nvim" },
			file_ignore_patterns = { ".class" },
			config = function()
				-- use telescope'
				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
				vim.keymap.set("n", "<leader>pf", builtin.git_files, {})
				vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
				vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
				vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
			end,
		},
		{
			"nvim-telescope/telescope-ui-select.nvim",
			config = function()
				require("telescope").setup({
					defaults = {
						layout_config = {
							horizontal = {
								preview_width = 0.6,
								width = 0.85,
							},
							vertical = {
								preview_height = 0.6,
								height = 0.85,
							},
						},
					},
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown({}),
						},
					},
				})
				require("telescope").load_extension("ui-select")
			end,
		},
	}
'';

".config/nvim/lua/plugins/themes.lua".text = '' 
	return {
		{
			"folke/tokyonight.nvim",
			name = "tokyonight",
			priority = 1000,
			config = function()
				-- Set default theme
				local themes = {
					"tokyonight-night",
					"tender",
					"catppuccin",
					"kanagawa",
					"rose-pine",
				}
	
				local current_theme_index = 1
				-- Set default theme (first theme)
				vim.cmd.colorscheme(themes[current_theme_index])
	
				-- Key mapping to switch themes (e.g., <leader>nt)
				vim.keymap.set("n", "<leader>nt", function()
					current_theme_index = current_theme_index + 1
					if current_theme_index > #themes then
						current_theme_index = 1
					end
					local theme = themes[current_theme_index]
					vim.cmd.colorscheme(theme)
					print("Change nvim theme to: " .. theme)
				end, { noremap = true, silent = true })
			end,
		},
		{
			"jacoborus/tender.vim",
			name = "tender",
			priority = 800,
		},
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 900,
		},
		{
			"rebelot/kanagawa.nvim",
			name = "kanagawa",
			priority = 910,
		},
		{
			"rose-pine/neovim",
			name = "rose-pine",
			priority = 910,
		},
	}
'';

".config/nvim/lua/plugins/tmux-navigator.lua".text = '' 
	return {
		"christoomey/vim-tmux-navigator",
		config = function()
			vim.keymap.set('n', 'C-h', ':TmuxNavigateLeft<CR>')
			vim.keymap.set('n', 'C-j', ':TmuxNavigateDown<CR>')
			vim.keymap.set('n', 'C-k', ':TmuxNavigateUp<CR>')
			vim.keymap.set('n', 'C-l', ':TmuxNavigateRight<CR>')
		end,
	}
'';

".config/nvim/lua/plugins/transparent.lua".text = '' 
	return {
		"xiyaowong/transparent.nvim",
		config = function()
			require("transparent").setup({
				enable = true,
				extra_groups = {
					"Normal",
					"NormalNC",
					"TelescopeBorder",
					"NvimTreeNormal",
					"LualineNormal",
				},
			})
			require("transparent").clear_prefix("NeoTree")
			require("transparent").clear_prefix("lualine")
			-- depends on pc, these settings are needed
			vim.cmd("highlight Normal guibg=NONE")
			vim.cmd("highlight Lualine guibg=NONE")
			vim.cmd("highlight Lualine guifg=NONE")
			vim.cmd("highlight NormalNC guibg=NONE")
			vim.cmd("highlight CursorLine guibg=NONE")
		end,
	}
'';

".config/nvim/lua/plugins/treesitter.lua".text = '' 
	return {
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local config = require("nvim-treesitter.configs")
			config.setup({
				-- auto install
				auto_install = true,
				-- add language you want to highlight in code
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"javascript",
					"html",
					"json",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	}
'';

".config/nvim/lua/plugins/undo-tree.lua".text = '' 
	return {
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
			vim.keymap.set("n", "<leader>uf", vim.cmd.UndotreeFocus)
		end,
	}
'';

".config/nvim/lua/plugins/warn-col.lua".text = '' 
	return {
	    "lukas-reineke/virt-column.nvim",
	    opts = {
	        char = {"┊"},
	        highlight = {"WarningMsg"},
	   }
	}
'';



		
    ############################# 	CONFIG WEZTERM    ###########################################
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
      TERMINAL = "wezterm";
	};
	############################# 	CONFIG GIT   ################################################
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
	############################# STARSHIP CONFIG (like oh my posh) #############################
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
	############################# TMUX CONFIG ###################################################
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
