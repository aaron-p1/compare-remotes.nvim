 local _local_1_ = vim local endswith = _local_1_["endswith"]
 local startswith = _local_1_["startswith"]
 local tbl_contains = _local_1_["tbl_contains"]
 local tbl_deep_extend = _local_1_["tbl_deep_extend"]
 local _local_2_ = _local_1_["api"] local nvim_tabpage_get_number = _local_2_["nvim_tabpage_get_number"] local nvim_echo = _local_2_["nvim_echo"] local nvim_create_user_command = _local_2_["nvim_create_user_command"]
 local _local_3_ = _local_1_["cmd"] local split = _local_3_["split"] local diffsplit = _local_3_["diffsplit"]
 local _local_4_ = _local_1_["fn"] local expand = _local_4_["expand"] local fnamemodify = _local_4_["fnamemodify"] local glob = _local_4_["glob"] local isdirectory = _local_4_["isdirectory"]
 local _local_5_ = _local_1_["keymap"] local kset = _local_5_["set"]


 local default_config = {remotes = {}, mapping = {key = "<Leader>cr", opts = {desc = "Compare remote file"}}, project_file_schemes = {}, scheme_replacements = {file = {}, dir = {}}}




 local project_file_schemes = default_config.project_file_schemes
 local scheme_replacements = default_config.scheme_replacements
 local remotes = default_config.remotes

 local function set_remotes(remote_map) _G.assert((nil ~= remote_map), "Missing argument remote-map on fennel/compare-remotes.fnl:20")
 do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for name, path_map in pairs(remote_map) do
 local val_19_auto = {name, path_map} if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end remotes = tbl_17_auto end return nil end

 local function get_remotes() local tbl_14_auto = {}
 for _, _7_ in ipairs(remotes) do local _each_8_ = _7_ local name = _each_8_[1] local path_map = _each_8_[2]
 local _9_, _10_ = name, path_map if ((nil ~= _9_) and (nil ~= _10_)) then local k_15_auto = _9_ local v_16_auto = _10_ tbl_14_auto[k_15_auto] = v_16_auto else end end return tbl_14_auto end

 local function replace_scheme(path, replacements) _G.assert((nil ~= replacements), "Missing argument replacements on fennel/compare-remotes.fnl:28") _G.assert((nil ~= path), "Missing argument path on fennel/compare-remotes.fnl:28")
 local scheme = string.gsub(path, "^(.+)://.+$", "%1")
 local replacement = replacements[scheme]
 if replacement then
 return string.gsub(path, "^.+://", (replacement .. "://")) else
 return path end end

 local function get_remote_path(remote_prefix, path, dir_3f) _G.assert((nil ~= dir_3f), "Missing argument dir? on fennel/compare-remotes.fnl:35") _G.assert((nil ~= path), "Missing argument path on fennel/compare-remotes.fnl:35") _G.assert((nil ~= remote_prefix), "Missing argument remote-prefix on fennel/compare-remotes.fnl:35")
 local replacements local _13_ if dir_3f then _13_ = "dir" else _13_ = "file" end replacements = scheme_replacements[_13_]
 local path_prefix = replace_scheme(remote_prefix, replacements)
 local function _15_() if endswith(path_prefix, "/") then return "" else return "/" end end return (path_prefix .. _15_() .. path) end

 local function entry_selected(local_path, _3fchoice) _G.assert((nil ~= local_path), "Missing argument local-path on fennel/compare-remotes.fnl:40")
 if _3fchoice then
 local _let_16_ = _3fchoice local _ = _let_16_[1] local remote_prefix = _let_16_[2]
 local dir_3f = (1 == isdirectory(local_path))
 local remote_path = get_remote_path(remote_prefix, local_path, dir_3f)
 local tab = nvim_tabpage_get_number(0)
 split({mods = {tab = tab, silent = true}})
 return diffsplit({mods = {vertical = true, silent = true}, remote_path}) else return nil end end

 local function open_remote_selection(local_path) _G.assert((nil ~= local_path), "Missing argument local-path on fennel/compare-remotes.fnl:49")
 local prompt = ("Select remote to compare " .. local_path .. " against")
 local function _18_(_241) return (_241)[1] end
 local function _19_(...) return entry_selected(local_path, ...) end return vim.ui.select(remotes, {prompt = prompt, format_item = _18_}, _19_) end

 local function project_file_3f(path) _G.assert((nil ~= path), "Missing argument path on fennel/compare-remotes.fnl:54")
 return (not startswith(path, "/") and ("" ~= glob(path))) end

 local function project_file_scheme_3f(path) _G.assert((nil ~= path), "Missing argument path on fennel/compare-remotes.fnl:57")
 local scheme = string.match(path, "^(.+)://")
 return (not scheme or tbl_contains(project_file_schemes, scheme)) end

 local function buf_path__3erelative_project_path(buf_path) _G.assert((nil ~= buf_path), "Missing argument buf-path on fennel/compare-remotes.fnl:61")
 local path_without_scheme = string.gsub(buf_path, "^.+://", "")
 local relative_path = fnamemodify(path_without_scheme, ":.")
 if (project_file_3f(relative_path) and project_file_scheme_3f(buf_path)) then
 return relative_path else return nil end end

 local function compare_remotes()
 local buf_path = expand("%:p")
 local project_file_path = buf_path__3erelative_project_path(buf_path)
 if project_file_path then
 return open_remote_selection(project_file_path) else
 return nvim_echo({{("Not a project file: " .. buf_path), "ErrorMsg"}}, false, {}) end end

 local function setup(_3fuser_config)
 local user_config = (_3fuser_config or {})
 local config = tbl_deep_extend("force", default_config, user_config)
 project_file_schemes = config.project_file_schemes
 scheme_replacements = config.scheme_replacements
 set_remotes(config.remotes)
 nvim_create_user_command("CompareRemotes", compare_remotes, {})
 if config.mapping then
 return kset("n", config.mapping.key, compare_remotes, config.mapping.opts) else return nil end end

 return {setup = setup, set_remotes = set_remotes, get_remotes = get_remotes, compare_remotes = compare_remotes}
