vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus' --  Schedule setting after `UiEnter` bc it may increase startup-time.
end)

-- set path
vim.env.PATH = 'C:/Users/garzall/.conda/envs/nvim/Scripts;' .. vim.env.PATH

-- settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.swapfile = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.have_nerd_font = false
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- setting maps
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })
vim.keymap.set('c', '<C-v>', '<C-r>+', { noremap = true, silent = true })
vim.keymap.set('', '<F13>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- small helper
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.api.nvim_set_option('ignorecase', true)
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { 'sitiom/nvim-numbertoggle' },

  {
    'robitx/gp.nvim',
    config = function()
      local conf = {
        providers = {
          anthropic = {
            endpoint = 'https://api.anthropic.com/v1/messages',
            secret = os.getenv 'ANTHROPIC_API_KEY',
          },
        },
      }
      require('gp').setup(conf)

      local function keymapOptions(desc)
        return { noremap = true, silent = true, nowait = true, desc = 'GPT prompt ' .. desc }
      end

      -- Chat commands
      vim.keymap.set({ 'n' }, '<leader>ac', '<cmd>GpChatNew<cr>', keymapOptions 'New Chat')
      vim.keymap.set({ 'n' }, '<leader>at', '<cmd>GpChatToggle<cr>', keymapOptions 'Toggle Chat')
      vim.keymap.set({ 'n' }, '<leader>af', '<cmd>GpChatFinder<cr>', keymapOptions 'Chat Finder')
      vim.keymap.set({ 'n', 'i' }, '<C-a>c', '<cmd>GpChatNew<cr>', keymapOptions 'New Chat')
      vim.keymap.set({ 'n', 'i' }, '<C-a>t', '<cmd>GpChatToggle<cr>', keymapOptions 'Toggle Chat')
      vim.keymap.set({ 'n', 'i' }, '<C-a>f', '<cmd>GpChatFinder<cr>', keymapOptions 'Chat Finder')
      vim.keymap.set('v', '<C-a>c', ":<C-u>'<,'>GpChatNew<cr>", keymapOptions 'Visual Chat New')
      vim.keymap.set('v', '<C-a>p', ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions 'Visual Chat Paste')

      -- Text manipulation commands
      vim.keymap.set({ 'n', 'i' }, '<C-a>r', '<cmd>GpRewrite<cr>', keymapOptions 'Inline Rewrite')
      vim.keymap.set({ 'n', 'i' }, '<C-a>a', '<cmd>GpAppend<cr>', keymapOptions 'Append (after)')
      vim.keymap.set({ 'n', 'i' }, '<C-a>b', '<cmd>GpPrepend<cr>', keymapOptions 'Prepend (before)')
      vim.keymap.set('v', '<C-a>r', ":<C-u>'<,'>GpRewrite<cr>", keymapOptions 'Visual Rewrite')
      vim.keymap.set('v', '<C-a>a', ":<C-u>'<,'>GpAppend<cr>", keymapOptions 'Visual Append (after)')
      vim.keymap.set('v', '<C-a>b', ":<C-u>'<,'>GpPrepend<cr>", keymapOptions 'Visual Prepend (before)')

      -- Whisper commands
      vim.keymap.set({ 'n', 'i' }, '<C-a>ww', '<cmd>GpWhisper<cr>', keymapOptions 'Whisper')
      vim.keymap.set('v', '<C-a>ww', ":<C-u>'<,'>GpWhisper<cr>", keymapOptions 'Visual Whisper')

      -- Other commands
      vim.keymap.set({ 'n', 'i' }, '<C-a>s', '<cmd>GpStop<cr>', keymapOptions 'Stop')
      vim.keymap.set({ 'n', 'i' }, '<C-a>n', '<cmd>GpNextAgent<cr>', keymapOptions 'Next Agent')
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
        { "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = '[G]it [L]azy (lazygit)' }
    }
  },

  {
    'tpope/vim-fugitive',

    config = function()
      vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<CR>', { desc = "Show Git differences" })
    end,
  },

  {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon').setup {
        global_settings = {
          save_on_toggle = true,
          save_on_change = true,
        },
      }
      vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })
      vim.keymap.set('n', '<leader>he', require('harpoon.ui').toggle_quick_menu, { desc = 'Harpoon Edit Menu' })
      for i = 1, 6 do
        vim.keymap.set('n', '<leader>h' .. i, function()
          require('harpoon.ui').nav_file(i)
        end, { desc = 'Go to File ' .. i })
      end
    end,
  },

  {
    'mluders/comfy-line-numbers.nvim',
    config = function()
      require('comfy-line-numbers').setup {
        labels = { '1','2','3','4','5','11','12','13','14','15','21','22','23','24','25',
                   '31','32','33','34','35','41','42','43','44','45','51','52','53','54','55',
                   '111','112','113','114','115','121','122','123','124','125','131','132','133','134','135',
                   '141','142','143','144','145','151','152','153','154','155',
                   '211','212','213','214','215','221','222','223','224','225',
                   '231','232','233','234','235','241','242','243','244','245',
                   '251','252','253','254','255' },
        up_key = 'k',
        down_key = 'j',
        hidden_file_types = { 'undotree' },
        hidden_buffer_types = { 'terminal', 'TelescopePrompt', 'TelescopeResults', 'harpoon' },
      }
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
          C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ', CR = '<CR> ', Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ', ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ', BS = '<BS> ', Space = '<Space> ', Tab = '<Tab> ',
          F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>', F5 = '<F5>',
          F6 = '<F6>', F7 = '<F7>', F8 = '<F8>', F9 = '<F9>', F10 = '<F10>',
          F11 = '<F11>', F12 = '<F12>',
        },
      },
    spec = {
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>g', group = '[G]it' },
    },
    },
  },

  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = { open_mapping = [[<C-\>]], direction = 'horizontal', start_in_insert = true },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      -- Exit terminal mode using <Esc> key
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

      -- Toggle different terminal instances using specific key mappings
      vim.keymap.set('n', '<C-\\>', function() require('toggleterm').toggle(1) end, { desc = 'Toggle terminal 1' })
      vim.keymap.set('n', '<C-]>', function() require('toggleterm').toggle(2) end, { desc = 'Toggle terminal 2' })
      vim.keymap.set('n', '<C-=>', function() require('toggleterm').toggle(3) end, { desc = 'Toggle terminal 3' })
    end
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      local state = require 'telescope.actions.state'
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { '.git' },
          mappings = {
            i = {
              ['<C-v>'] = function(prompt_bufnr)
                local picker = state.get_current_picker(prompt_bufnr)
                local clipboard_content = vim.fn.getreg '+'
                if clipboard_content and clipboard_content ~= '' then
                  picker:reset_prompt(clipboard_content)
                else
                  print 'Clipboard is empty or inaccessible.'
                end
              end,
            },
          },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' },
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Search [F]iles' })
      vim.keymap.set('n', '<leader>s', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>Sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>Sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>Sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>Sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>Ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>Sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>Sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>S.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>Sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup { default_command = 'Oil', view_options = { show_hidden = true } }
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } } } },
  { 'Bilal2453/luvit-meta', lazy = true },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references,  '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]oc [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        end,
      })

      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
      )

      -- Use a MAP so tbl_keys returns server names (strings), not numbers.
      local servers = {}  --omit tsserver bc of ts tools

      -- Tools managed by mason-tool-installer (LSPs + formatters/linters/etc.)
      local ensure = vim.tbl_keys(servers)
      -- vim.list_extend(ensure, {
      --   -- 'stylua',  -- Lua formatter
      --   -- add other formatters/linters you want ensured globally
      -- })

      require('mason-tool-installer').setup({ ensure_installed = ensure })

      require('mason-lspconfig').setup({
        automatic_installation = true,
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            -- skip tsserver/ts_ls here if you keep typescript-tools
            if server_name == 'tsserver' or server_name == 'ts_ls' then
              return
            end
            local server_config = servers[server_name] or {}
            server_config.capabilities = vim.tbl_deep_extend(
              'force',
              {},
              capabilities,
              server_config.capabilities or {}
            )
            require('lspconfig')[server_name].setup(server_config)
          end,
        },
      })
    end,
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      on_attach = function(client)
        -- disable tsserver formatting
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    },
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      { '<leader>cf', function() require('conform').format { async = true, lsp_fallback = true } end, mode = 'n', desc = '[C]ode [F]ormat' },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true, tsx = true }
        local filetype = vim.bo[bufnr].filetype
        if disable_filetypes[filetype] then return end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      formatters = {
        black = { command = 'C:/Users/garzall/.conda/envs/nvim/Scripts/black.exe', args = { '--quiet', '-' }, stdin = true },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        json = { 'prettier' },
      },
    },
    config = function(_, opts) require('conform').setup(opts) end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          {
            name = 'lazydev',
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- load this before all the other start plugins !
    init = function()
      vim.cmd.colorscheme 'tokyonight-moon'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- simple and easy statusline.
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  { -- highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  { import = 'kickstart.plugins.lint' },
  { import = 'custom.plugins' },

})
-- -- vim: ts=2 sts=2 sw=2 et
