-- 📌 Базовые настройки
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.syntax = "on"

-- 📌 Настройка вертикальной линии справа (colorcolumn)
vim.opt.colorcolumn = "120"  -- можно задать другое число, если нужно

-- 📌 Подсветка текущей строки (с тонким подчеркиванием)
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, "CursorLine", { underline = true, bg = "none" })

-- 📌 Установка lazy.nvim (если его нет)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- 📌 Подключение плагинов через lazy.nvim
require("lazy").setup({
    "neovim/nvim-lspconfig",         -- LSP (clangd)
    "hrsh7th/nvim-cmp",              -- Автодополнение
    "hrsh7th/cmp-nvim-lsp",          -- LSP в автодополнении
    "nvim-tree/nvim-tree.lua",       -- Файловый менеджер
    "nvim-telescope/telescope.nvim", -- Поиск файлов
    "mfussenegger/nvim-dap",         -- Отладчик
    "mhartington/formatter.nvim",    -- Форматирование
    "nvim-lualine/lualine.nvim",     -- Статусная строка
    "windwp/nvim-autopairs",         -- Автозакрытие скобок
    "folke/tokyonight.nvim",         -- Тема
    "NLKNguyen/papercolor-theme",
    "akinsho/toggleterm.nvim",       -- Терминал для сборки и запуска
    "lukas-reineke/indent-blankline.nvim"  -- Подсветка отступов
})

-- 📌 Установка темы
vim.cmd("colorscheme torte")

-- 📌 Настройка LSP (clangd для C++)
local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
    on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- Перейти к определению в новой вкладке
        vim.keymap.set("n", "gd", function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
                if result == nil or vim.tbl_isempty(result) then
                    print("[LSP] Definition not found")
                    return
                end

                local def = result[1]
                if def.targetUri then
                    def = def.targetUri and def or def[1]
                    def.uri = def.targetUri
                    def.range = def.targetSelectionRange
                end

                local fname = vim.uri_to_fname(def.uri)
                vim.cmd("tabnew " .. fname)
                vim.api.nvim_win_set_cursor(0, { def.range.start.line + 1, def.range.start.character })
            end)
        end, opts)

        -- Поиск ссылок
        vim.keymap.set("n", "<C-o>", vim.lsp.buf.references, opts)
    end,
})

-- 📌 Настройка автодополнения
local cmp = require("cmp")
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
    }),
})

-- 📌 Автозакрытие скобок
require("nvim-autopairs").setup({
    check_ts = true,
    disable_filetype = { "TelescopePrompt" },
})

-- 📌 Файловый менеджер
require("nvim-tree").setup()

-- 📌 Форматирование кода (clang-format)
require("formatter").setup({
    filetype = {
        cpp = {
            function()
                return {
                    exe = "clang-format",
                    args = {},
                    stdin = true
                }
            end
        }
    }
})

-- 📌 Поиск файлов (Telescope)
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true })

-- 📌 Открытие файлового менеджера
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- 📌 Настройка терминала (для сборки и запуска)
require("toggleterm").setup({
    direction = "float",
    shell = "/bin/bash",
    close_on_exit = false
})

-- 📌 Функция для компиляции и запуска C++
function CompileAndRun()
    local file = vim.fn.expand("%")         -- Получаем имя текущего файла
    local output = vim.fn.expand("%:r")       -- Имя без расширения
    local cmd = "g++ " .. file .. " -o " .. output .. " && ./" .. output

    require("toggleterm.terminal").Terminal
        :new({ cmd = cmd, direction = "float", close_on_exit = false })
        :toggle()
end

-- 📌 Горячая клавиша для компиляции и запуска
vim.api.nvim_set_keymap("n", "<leader>r", ":lua CompileAndRun()<CR>", { noremap = true, silent = true })

require("ibl").setup()
