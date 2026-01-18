-- リーダーキーの設定
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 基本設定
vim.opt.number = true           -- 行番号を表示
vim.opt.clipboard = "unnamedplus" -- システムクリップボードを使用
vim.opt.expandtab = true        -- タブをスペースに変換
vim.opt.tabstop = 2             -- タブ幅を2に設定
vim.opt.shiftwidth = 2          -- インデント幅を2に設定

-- ヘルパー関数
local function extract_real_path(path)
  -- fugitiveのパスから実際のファイルパスを抽出
  if path:match("^fugitive://") then
    local real_path = vim.fn.FugitiveReal(path)
    if real_path:match("^fugitive://") then
      real_path = real_path:match("/%.git/.-//%d+/(.*)$") or real_path
    end
    return real_path
  end
  return path
end

local function get_relative_path(path)
  -- 絶対パスの場合は相対パスに変換
  if path:match("^/") then
    return vim.fn.fnamemodify(path, ":.")
  end
  return path
end

local function get_current_file_path()
  local path = vim.fn.expand("%")
  path = extract_real_path(path)
  return get_relative_path(path)
end

-- キーマッピング
vim.keymap.set("i", "jj", "<ESC>", { desc = "jjでインサートモードを抜ける" })

-- ファイルパス関連
vim.keymap.set("n", "<leader>cp", function()
  local path = get_current_file_path()
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>cpa", function()
  local path = vim.fn.expand("%:p")
  path = extract_real_path(path)
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy absolute file path" })

-- ファイルパスとコード選択範囲をコピー
vim.keymap.set("v", "<leader>cc", function()
  local path = get_current_file_path()
  
  -- 選択範囲のテキストを取得
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  
  -- フォーマットを作成
  local formatted = "@" .. path .. "\n\n```\n" .. selected_text .. "\n```"
  
  vim.fn.setreg("+", formatted)
  print("Copied: @" .. path .. " with selected text")
end, { desc = "Copy file path with selected code" })

-- GitHub でファイルを開く
vim.keymap.set("n", "<leader>gh", function()
  local path = get_current_file_path()
  vim.cmd("!gh browse " .. path .. " --commit")
  print("Opening: " .. path .. " in GitHub at current commit")
end, { desc = "Open file in GitHub at current commit" })

-- GitHub でファイルを行番号付きで開く（ビジュアルモード）
vim.keymap.set("v", "<leader>gh", function()
  local path = get_current_file_path()
  
  -- 選択範囲を取得（ビジュアルモード中に取得）
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  
  -- 開始行と終了行を正しい順序にする
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  
  -- 行番号が0の場合は現在行を使用
  if start_line == 0 then
    start_line = vim.fn.line(".")
  end
  
  local line_part
  if start_line == end_line then
    line_part = ":" .. start_line
  else
    line_part = ":" .. start_line .. "-" .. end_line
  end
  
  vim.cmd("!gh browse " .. path .. line_part .. " --commit")
  if start_line == end_line then
    print("Opening: " .. path .. " line " .. start_line .. " in GitHub at current commit")
  else
    print("Opening: " .. path .. " lines " .. start_line .. "-" .. end_line .. " in GitHub at current commit")
  end
end, { desc = "Open file in GitHub with selected lines at current commit" })

-- Finder でファイルを開く（macOS）
vim.keymap.set("n", "<leader>fo", function()
  local path = vim.fn.expand("%:p")
  path = extract_real_path(path)
  vim.cmd("!open -R " .. vim.fn.shellescape(path))
  print("Opening in Finder: " .. path)
end, { desc = "Open file in Finder" })

-- 設定再読み込み（lazy.nvim対応）
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("Lazy reload")
  print("Config reloaded!")
end, { desc = "Reload config" })

-- lazy.nvimのセットアップ
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

-- プラグインの設定
require("lazy").setup({
  -- Neo-tree（ファイルエクスプローラー）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 30,
        },
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
      vim.keymap.set("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus Neo-tree" })
    end,
  },

  -- Telescope（ファジーファインダー）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.DS_Store"
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
          },
        },
      })
      
      local builtin = require("telescope.builtin")
      -- 一般的なTelescope keymaps
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    end,
  },

  -- LSP Configuration
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls" },
      })

      -- Neovim 0.11+ の新しい LSP 設定 API を使用
      vim.lsp.config('ts_ls', {
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      })
      vim.lsp.enable('ts_ls')

      -- LSPAttachイベントを使用してキーマッピングを設定
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<F24>', vim.lsp.buf.references, opts)  -- Shift+F12
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        end,
      })
    end,
  },

})