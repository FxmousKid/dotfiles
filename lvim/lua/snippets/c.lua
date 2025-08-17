-- DOXFILE
local ls  = require("luasnip")
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local c   = ls.choice_node
local f   = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function today() return os.date("%Y-%m-%d") end
local function git_user()
  local h = io.popen('git config user.name 2>/dev/null')
  local v = h and h:read("*l") or ""
  if h then h:close() end
  return (v ~= "" and v) or "Your Name"
end
local function git_ver()
  local h = io.popen('git describe --tags --always 2>/dev/null')
  local v = h and h:read("*l") or ""
  if h then h:close() end
  return (v ~= "" and v) or "0.1"
end

ls.add_snippets("all", {
  s("doxfile", fmt([[
/**
 * @file {}
 * @brief {}
 * @ingroup {}
 *
 * @author {}
 * @date {}
 * @version {}
 *
 * @details
 *  {}
 */
]], {
    f(function(_, snip) return vim.fn.expand("%:t") end),               -- filename
    i(1, "One-sentence purpose of this file."),
    c(2, { i(nil, "icmp"), i(nil, "net"), i(nil, "cli"), i(nil, "stats"), i(nil, "core") }),
    f(git_user), f(today), f(git_ver),
    i(0, "Longer description if useful."),
  })),
})

-- DOXCONST
ls.add_snippets("all",{
  s("doxconst", fmt([[
/** @brief {}. */
]], {
    i(1, "Nice little variable."),
  })),
})
