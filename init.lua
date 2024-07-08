-- Dependencies:
--
-- Rust
--   https://www.rust-lang.org/tools/install
--   GitLab CI Language Server
--     cargo install gitlab-ci-ls
-- .Net SDK
--   https://dotnet.microsoft.com/en-us/download
-- PowerShell Editor Services
--   https://github.com/PowerShell/PowerShellEditorServices/releases
--   Unzip PowerShellEditorServices.zip into %USERPROFILE%\Downloads\PowerShellEditorServices
-- PHP Actor
--   Windows: https://windows.php.net/download/
--   Linux: apt install php
--   Both: Make "phpactor" be in your path, and execute this with php:
--     https://github.com/phpactor/phpactor/releases/latest/download/phpactor.phar
-- Vue
--   npm -g install @vue/typescript-plugin
--   Set path below to lspconfig tsserver location where node is installed
-- Font
--   "0xProto Nerd Font"
--   https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/0xProto.zip
-- Highlighting
--   npm -g install tree-sitter-javascript
--   npm -g install tree-sitter-css
--

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Set GUI font
vim.o.guifont = "0xProto Nerd Font:h8:Consolas"
vim.g.have_nerd_font = true

-- Enable line numbers
vim.opt.number = true

-- Enable relative line numbers
vim.opt.relativenumber = true

-- Enable mouse
vim.opt.mouse = "a"

-- Don't show mode since it's in the statusline
vim.opt.showmode = false

-- Enable OS clipboard sync
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching
vim.opt.ignorecase = true

-- Case-sensitive searching if \C or any capital letters in search
vim.opt.smartcase = true

-- Enable signcolumn
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Display which-key popup earlier
vim.opt.timeoutlen = 300

-- Open horizontal splits to the right
vim.opt.splitright = true

-- Open vertical splits below
vim.opt.splitbelow = true

-- Preview substitutions as you type
vim.opt.inccommand = "split"

-- Highlight the line your cursor is on
vim.opt.cursorline = true

-- Adds space above and below to see what's coming up
vim.opt.scrolloff = 10

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Highlight while yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Remember the last cursor place when reloding NeoVim
local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_clear_autocmds({ group = lastplace })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = lastplace,
	pattern = { "*" },
	desc = "remember last cursor place",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({

	-- IDE bar for breadcrumbs
	{
		"Bekaboo/dropbar.nvim",
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
		},
	},

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- Type "gc" when selected to comment/uncomment lines
	{ "numToStr/Comment.nvim", opts = {} },

	-- Git symbols on left bar
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- Display the available next keypress above the statusline
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("which-key").setup()
			require("which-key").register({
				["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
				["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
				["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
				["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
				["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
				["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
				["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
			})
			require("which-key").register({
				["<leader>h"] = { "Git [H]unk" },
			}, { mode = "v" })
		end,
	},

	-- Fuzzy Finder
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {

			-- Async and general puropse library for neovim lua
			"nvim-lua/plenary.nvim",
			{

				-- Fuzzy Finder executable
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},

			-- Sets telescope as NeoVim's default selector
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Web DevIcons are available if a nerdfont is used
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Add fuzzy finder extension for Telescope
			pcall(require("telescope").load_extension, "fzf")

			-- Add ui-select extension for Telescope
			pcall(require("telescope").load_extension, "ui-select")

			-- Enable a default set of telescope built-in functions
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- Simple <leader>/ bind for fuzzy find in the current buffer
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			-- Grep in open files
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Search NeoVim config files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},
	-- Java support
	"nvim-java/nvim-java",

	{ -- Language Server Protocol (LSP) server configuration
		"neovim/nvim-lspconfig",
		dependencies = {

			-- Setup LSPs automatically
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates from LSP in lower right corner
			{ "j-hui/fidget.nvim", opts = {} },

			-- LSP completion for NeoVim APIs
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			local userprofile = os.getenv("USERPROFILE")
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Go to definition of the word under the cursor
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Go to references of the word under the cursor
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Go to the implementation of the word under the cursor.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Show type definition for the variable under the cursor
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find only symbols in this document
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find only the symbols in your current workspace.
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under the cursor across files in the project
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Run a code action for the error under the cursor
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					-- Opens a popup that displays documentation about the word under the cursor
					map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- Go to the declaration of the variable under the cursor
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Highlight all visible references of the word under the cursor
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Allow user to enable/disable inlay hints from the LSP
					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Create capabilities to broadcast to LSP servers that need to know
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- Optional keys to pass to servers:
			-- - cmd (table): Override the default command used to start the server
			-- - filetypes (table): Override the default list of associated filetypes for the server
			-- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			-- - settings (table): Override the default settings passed when initializing the server.
			local servers = {
				pyright = {}, -- Python
				tsserver = {}, -- TypeScript, JavaScript
				lua_ls = { -- Lua
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = {
									"vim",
								},
								disable = {
									"missing-fields",
								},
							},
						},
					},
				},
				vuels = {}, -- Vue.js
				powershell_es = { -- PowerShell
					bundle_path = userprofile .. "/Downloads/PowerShellEditorServices",
				},
				ansiblels = {}, -- Ansible
				autotools_ls = {}, -- AutoConf/AutoMake
				bashls = {}, -- Bash
				cmake = {}, -- CMake
				csharp_ls = {}, -- C#
				css_variables = {}, -- CSS Variables
				cssls = { -- CSS
					capabilities = capabilities,
				},
				cssmodules_ls = {}, -- CSS Modules
				docker_compose_language_service = {}, -- Docker Compose
				dockerls = {}, -- Dockerfile
				gitlab_ci_ls = {}, -- Gitlab CI/CD
				gopls = {}, -- Go
				html = { -- HTML
					capabilities = capabilities,
				},
				htmx = {}, -- HTMX
				jdtls = {}, -- Java
				intelephense = {}, -- PHP
				jqls = {}, -- JQ
				jsonls = {}, -- JSON
				nginx_language_server = {}, -- Nginx
				perlnavigator = {}, -- Perl
				rust_analyzer = {}, -- Rust
				sqlls = {}, -- SQL
				vacuum = {}, -- OpenAPI/Swagger,
				yamlls = {}, -- YAML
			}

			-- Automatically install servers
			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,

					-- Setup PowerShell Editor Services manually since not supported natively by lspconfig
					powershell_es = function()
						local lspconfig = require("lspconfig")
						lspconfig.powershell_es.setup({
							bundle_path = userprofile .. "/Downloads/PowerShellEditorServices",
							on_attach = function(_, bufnr)
								vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
								local bufopts = { noremap = true, silent = true, buffer = bufnr }
								vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
								vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
								vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
								vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
								vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
								vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
								vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
								vim.keymap.set("n", "<Leader>f", function()
									vim.lsp.buf.format({ async = true })
								end, bufopts)
								vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
								vim.keymap.set("n", "<Leader>td", vim.lsp.buf.type_definition, bufopts)
							end,
						})
					end,
				},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Certain filetypes don't really have coding style standards
				local disable_filetypes = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				vue = { "prettier" },
				go = { "gofmt" },
				python = { "isort", "black" },
			},
		},
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {

			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},

			-- Luasnip completion sourse for nvim-cmp
			"saadparwaiz1/cmp_luasnip",

			-- LSP source for nvim-cmp
			"hrsh7th/cmp-nvim-lsp",

			-- Filesystem source for nvim-cmp
			"hrsh7th/cmp-path",

			-- Fancy icons
			"onsails/lspkind-nvim",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local luasnip = require("luasnip")
			luasnip.config.setup({})
			cmp.setup({
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
					}),
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- Completion mapping
				mapping = cmp.mapping.preset.insert({

					-- Next item
					["<Down>"] = cmp.mapping.select_next_item(),

					-- Previous item
					["<Up>"] = cmp.mapping.select_prev_item(),

					-- Scroll up the documentation window
					["<C-Up>"] = cmp.mapping.scroll_docs(-4),

					-- Scroll down the documentation window
					["<C-Down>"] = cmp.mapping.scroll_docs(4),

					-- Confirm the selection
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),

					-- Manually trigger a completion
					["<C-Space>"] = cmp.mapping.complete({}),

					-- Move to the right of the snippet expansion
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),

					-- Move to the left of the snippet expansion
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})

			-- Colors for completion
			vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
			vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
			vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
			vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
			vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
			vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
			vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
			vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
			vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
		end,
	},

	-- Colorschemes
	{
		-- Browse/test with :Telescope colorscheme
		"tomasiser/vim-code-dark",
		-- Must be loaded before other plugins
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("codedark")
			vim.cmd.hi("Comment gui=none")
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Mini plugin bundle
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			-- Statusline
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		config = function()
			require("scrollbar").setup()
		end,
	},

	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"c_sharp",
				"cmake",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown_inline",
				"vim",
				"vimdoc",
				"vue",
				"javascript",
				"css",
				"csv",
				"cuda",
				"devicetree",
				"diff",
				"gitcommit",
				"gitignore",
				"go",
				"ini",
				"java",
				"jq",
				"jsdoc",
				"json",
				"kconfig",
				"make",
				"ninja",
				"org",
				"passwd",
				"perl",
				"php",
				"python",
				"regex",
				"requirements",
				"rust",
				"scss",
				"sql",
				"ssh_config",
				"strace",
				"tcl",
				"tmux",
				"typescript",
				"xml",
				"yaml",
				"norg",
			},
			ignore_insatll = { "org" },
			-- Autoinstall languages that are not installed
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				-- Exclude ruby due to incompatibility
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)
			local userprofile = os.getenv("USERPROFILE")
			-- Prefer git instead of curl in order to improve connectivity in some environments
			require("nvim-treesitter.install").prefer_git = true
			require("nvim-treesitter.configs").setup(opts)
			local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()

			-- Add powershell support manually
			treesitter_parser_config.powershell = {
				install_info = {
					url = userprofile .. "/AppData/Local/nvim/tparsers/tree-sitter-powershell",
					files = { "src/parser.c", "src/scanner.c" },
					branch = "main",
					generate_requires_npm = false,
					requires_generate_from_grammar = false,
				},
				filetype = "ps1",
			}
			vim.treesitter.language.register("powershell", "powershell")
		end,
	},

	-- Automatically close {[(<>)]}
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup({})
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Edit files over ssh with :edit scp://user@example.com/something
	{
		"nat-418/scamp.nvim",
		config = function()
			require("scamp").setup()
		end,
	},

	{ -- Linting
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				markdown = { "markdownlint" },
				javascript = { "eslint" },
				vue = { "eslint" },
				python = { "pylint" },
				ansible = { "ansible_lint" },
				html = { "htmlhint" },
				json = { "jsonlint" },
				lua = { "luacheck" },
				perl = { "perlcritic" },
				php = { "php" },
				sql = { "sqlfluff" },
				systemd = { "systemdlint" },
				yaml = { "yamllint" },
			}

			-- Lint on save
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- File manager, toggle with Ctrl-n or \
	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			{
				"s1n7ax/nvim-window-picker",
				version = "2.*",
				config = function()
					require("window-picker").setup({
						filter_rules = {
							include_current_win = false,
							autoselect_one = true,
							bo = {
								filetype = { "neo-tree", "neo-tree-popup", "notify" },
								buftype = { "terminal", "quickfix" },
							},
						},
					})
					vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
					vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
					vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
					vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })
				end,
			},
		},
		cmd = "Neotree",
		keys = {
			{ "\\", ":Neotree reveal<CR>", { desc = "NeoTree reveal" } },
			{ "<C-n>", ":Neotree reveal<CR>", { desc = "NeoTree reveal" } },
		},
		opts = {
			source_selector = {
				winbar = true,
				statusline = false,
			},
			popup_border_style = "rounded",
			enable_git_status = "true",
			enable_diagnostics = "true",
			open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
			sort_case_insensitive = true,
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indet = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = nil,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						-- Change type
						added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
						modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
						deleted = "✖", -- this can only be used in the git_status source
						renamed = "󰁕", -- this can only be used in the git_status source
						-- Status type
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				file_size = {
					enabled = true,
					required_width = 64,
				},
				type = {
					enabled = true,
					required_width = 122,
				},
				last_modified = {
					enabled = true,
					required_width = 88,
				},
				created = {
					enabled = true,
					required_width = 110,
				},
				symlink_target = {
					enabled = false,
				},
			},
			window = {
				position = "left",
				width = 40,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = {
						"toggle_node",
						nowait = false,
					},
					["<2-LeftMouse>"] = "open",
					["<esc>"] = "cancel",
					["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
					["l"] = "focus_preview",
					["S"] = "split_with_window_picker",
					["s"] = "vsplit_with_window_picker",
					["t"] = "open_tabnew",
					["<cr>"] = "open_drop",
					["w"] = "open_with_window_picker",
					["C"] = "close_node",
					["z"] = "close_all_nodes",
					["a"] = {
						"add",
						config = {
							show_path = "none",
						},
					},
					["A"] = "add_directory",
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
					["i"] = "show_file_details",
				},
			},
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,
				},
				follow_current_file = {
					enabled = false,
					leave_dirs_open = false,
				},
				group_empty_dirs = false,
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
				window = {
					mappings = {
						["\\"] = "close_window",
						["<C-n>"] = "close_window",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["H"] = "toggle_hidden",
						["/"] = "fuzzy_finder",
						["D"] = "fuzzy_finder_directory",
						["#"] = "fuzzy_sorter",
						["f"] = "filter_on_submit",
						["<c-x>"] = "clear_filter",
						["[g"] = "prev_git_modified",
						["]g"] = "next_git_modified",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["og"] = { "order_by_git_status", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
					fuzzy_finder_mappings = {
						["<down>"] = "move_cursor_down",
						["<C-n>"] = "move_cursor_down",
						["<up>"] = "move_cursor_up",
						["<C-p>"] = "move_cursor_up",
					},
				},
			},
			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				show_unloaded = true,
				window = {
					mappings = {
						["bd"] = "buffer_delete",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			git_status = {
				window = {
					position = "float",
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
		},
	},

	-- Greeter
	{
		"goolord/alpha-nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local alpha = require("alpha")
			local startify = require("alpha.themes.startify")
			startify.section.header.val = {
				[[███╗   ██╗██╗ ██████╗███████╗███████╗██╗  ██╗ ██████╗ ████████╗]],
				[[████╗  ██║██║██╔════╝██╔════╝██╔════╝██║  ██║██╔═══██╗╚══██╔══╝]],
				[[██╔██╗ ██║██║██║     █████╗  ███████╗███████║██║   ██║   ██║   ]],
				[[██║╚██╗██║██║██║     ██╔══╝  ╚════██║██╔══██║██║   ██║   ██║   ]],
				[[██║ ╚████║██║╚██████╗███████╗███████║██║  ██║╚██████╔╝   ██║   ]],
				[[╚═╝  ╚═══╝╚═╝ ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ]],
			}
			alpha.setup(startify.config)
		end,
	},

	-- Workspaces (Projects)
	{
		"natecraddock/workspaces.nvim",
		config = function()
			require("workspaces").setup({
				hooks = {
					open = "Neotree reveal",
				},
			})
			local telescope = require("telescope")
			telescope.load_extension("workspaces")
			vim.keymap.set(
				"n",
				"<leader>sp",
				":Telescope workspaces<CR>",
				{ desc = "[S]earch Workspaces ([P]rojects)" }
			)
			vim.keymap.set("n", "<leader>ap", ":WorkspacesAdd <name> <path>", { desc = "[A]dd Workspace ([P]roject)" })
			vim.keymap.set("n", "<leader>ad", ":WorkspacesAddDir <path>", { desc = "[A]dd Workspaces in directory" })
			vim.keymap.set("n", "<leader>dp", ":WorkspacesRemove <name>", { desc = "[D]elete Workspace ([P]roject)" })
			vim.keymap.set(
				"n",
				"<leader>dd",
				":WorkspacesRemoveDir <name>",
				{ desc = "[D]elese Workspaces in directory" }
			)
		end,
	},
	{
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		ft = { "org" },
		config = function()
			local userprofile = os.getenv("USERPROFILE")
			require("orgmode").setup({
				org_agenda_files = userprofile .. "/Downloads/org/**/*",
				org_default_notes_file = userprofile .. "/Downloads/org/refile.org",
			})
		end,
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et
