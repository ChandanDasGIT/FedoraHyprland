-- put user settings here
-- this module will be loaded after everything else when the application starts
-- it will be automatically reloaded when saved

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

-- 1. Use your installed JetBrains Mono Nerd Font
local font_path = os.getenv("HOME") .. "/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf"

-- 2. Force grayscale antialiasing to bypass the buggy FreeType subpixel call
local clean_font = renderer.font.load(font_path, 14 * SCALE, {
  antialiasing = "grayscale",
  hinting = "slight"
})

-- 3. Apply to UI, editor code, and syntax tokens
style.font = clean_font
style.code_font = clean_font
style.syntax_font = clean_font

if not rawget(_G, "TREEVIEW_INITIALIZED") then
  rawset(_G, "TREEVIEW_INITIALIZED", true)

  core.add_thread(function()
    coroutine.yield()
    coroutine.yield()
    command.perform("treeview:toggle")
  end)
end

-- Options: "word" (wraps at word boundaries) or "letter" (hard breaks anywhere)
config.plugins.linewrapping.mode = "word"

-- Enable line wrapping by default on all opened files
config.plugins.linewrapping.enable = true
------------------------------ Themes ----------------------------------------

-- light theme:
-- core.reload_module("colors.summer")

--------------------------- Key bindings -------------------------------------

-- key binding:
-- keymap.add { ["ctrl+escape"] = "core:quit" }

-- pass 'true' for second parameter to overwrite an existing binding
-- keymap.add({ ["ctrl+pageup"] = "root:switch-to-previous-tab" }, true)
-- keymap.add({ ["ctrl+pagedown"] = "root:switch-to-next-tab" }, true)

------------------------------- Fonts ----------------------------------------

-- customize fonts:
-- style.font = renderer.font.load(DATADIR .. "/fonts/FiraSans-Regular.ttf", 14 * SCALE)
-- style.code_font = renderer.font.load(DATADIR .. "/fonts/JetBrainsMono-Regular.ttf", 14 * SCALE)
--
-- DATADIR is the location of the installed Lite XL Lua code, default color
-- schemes and fonts.
-- USERDIR is the location of the Lite XL configuration directory.
--
-- font names used by lite:
-- style.font          : user interface
-- style.big_font      : big text in welcome screen
-- style.icon_font     : icons
-- style.icon_big_font : toolbar icons
-- style.code_font     : code
--
-- the function to load the font accept a 3rd optional argument like:
--
-- {antialiasing="grayscale", hinting="full", bold=true, italic=true, underline=true, smoothing=true, strikethrough=true}
--
-- possible values are:
-- antialiasing: grayscale, subpixel
-- hinting: none, slight, full
-- bold: true, false
-- italic: true, false
-- underline: true, false
-- smoothing: true, false
-- strikethrough: true, false

------------------------------ Plugins ----------------------------------------

-- disable plugin loading setting config entries:

-- disable plugin detectindent, otherwise it is enabled by default:
-- config.plugins.detectindent = false

---------------------------- Miscellaneous -------------------------------------

-- modify list of files to ignore when indexing the project:
-- config.ignore_files = {
--   -- folders
--   "^%.svn/",        "^%.git/",   "^%.hg/",        "^CVS/", "^%.Trash/", "^%.Trash%-.*/",
--   "^node_modules/", "^%.cache/", "^__pycache__/",
--   -- files
--   "%.pyc$",         "%.pyo$",       "%.exe$",        "%.dll$",   "%.obj$", "%.o$",
--   "%.a$",           "%.lib$",       "%.so$",         "%.dylib$", "%.ncb$", "%.sdf$",
--   "%.suo$",         "%.pdb$",       "%.idb$",        "%.class$", "%.psd$", "%.db$",
--   "^desktop%.ini$", "^%.DS_Store$", "^%.directory$",
-- }

