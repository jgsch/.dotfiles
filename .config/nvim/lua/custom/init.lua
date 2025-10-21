return {
  {
    'LazyVim/LazyVim',
    init = function()
      --
      -- mappings
      --

      -- Type jk for escape in insert mode
      vim.keymap.set('i', 'jk', '<Esc>')

      -- Make line numbers relative
      vim.opt.relativenumber = true

      -- Keybinds to move selected text
      vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected text upperward' })
      vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected text downward' })

      -- Keybinds to comment text
      vim.keymap.set('n', '<leader>c', 'gcc', { desc = 'Comment toggle', remap = true })
      vim.keymap.set('v', '<leader>c', 'gc', { desc = 'Comment toggle', remap = true })

      -- Keybinds to make split navigation easier. Use ALT+<hjkl> to switch between windows
      vim.keymap.set('n', '<A-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
      vim.keymap.set('n', '<A-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
      vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
      vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

      -- Diagnostic keymaps
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostics for line under cursor' })

      -- Keybinds to make split navigation easier.
      vim.keymap.set('n', '<C-p>', 'A\n# fmt: off\nimport ipdb; ipdb.set_trace()\n# fmt: on\n<Esc>', { desc = 'Insert python debugger' })

      --
      vim.keymap.set('n', '<leader>s', ':SearchBoxReplace<CR>')
      vim.keymap.set('x', '<leader>s', ':SearchBoxReplace visual_mode=true<CR>')

      --
      --
      --
      function ReplaceWordInSelection()
        local word = vim.fn.input 'Word to replace: '
        local replacement = vim.fn.input 'Replacement: '

        -- Get the visual selection range
        local visual_start_line, _ = unpack(vim.fn.getpos "'<", 2, 3)
        local visual_end_line, _ = unpack(vim.fn.getpos "'>", 2, 3)

        -- Helper to check if a word exists in a given range
        local function word_exists_in_range(start_line, end_line, word_to_replace)
          for line = start_line, end_line do
            local current_line = vim.fn.getline(line)
            if string.find(current_line, word_to_replace) then
              return true
            end
          end
          return false
        end

        -- Check if the word exists in the selected range
        if not word_exists_in_range(visual_start_line, visual_end_line, word) then
          vim.api.nvim_echo({ { ' Pattern not found: ' .. word, 'ErrorMsg' } }, true, {})
          return
        end

        -- Apply replacement within the selected range
        vim.cmd(visual_start_line .. ',' .. visual_end_line .. 's/' .. word .. '/' .. replacement .. '/g')
      end

      -- Map the <super>rw shortcut
      -- Keybinds to make split navigation easier.
      vim.api.nvim_set_keymap('v', '<leader>rw', ':lua ReplaceWordInSelection()<CR>', { noremap = true, silent = true })

      --
      -- lsp
      --

      -- Python

      vim.lsp.config('pyright', {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              typeCheckingMode = 'off',
              autoImportCompletions = true,
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            -- logLevel = 'error',
            -- lineLength = 100,
            lint = { select = { 'E', 'F' } },
            format = { preview = false },
          },
        },
      })

      -- Rust

      vim.lsp.config('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            check = { command = 'clippy' },
          },
        },
      })

      vim.lsp.enable { 'pyright', 'ruff', 'rust_analyzer' }
    end,
  },
}
