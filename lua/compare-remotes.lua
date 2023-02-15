 local _local_1_ = vim local endswith = _local_1_["endswith"]
 local startswith = _local_1_["startswith"]
 local tbl_contains = _local_1_["tbl_contains"]
 local validate = _local_1_["validate"]
 local tbl_extend = _local_1_["tbl_extend"]
 local _local_2_ = _local_1_["api"] local nvim_tabpage_get_number = _local_2_["nvim_tabpage_get_number"] local nvim_echo = _local_2_["nvim_echo"] local nvim_create_user_command = _local_2_["nvim_create_user_command"]
 local _local_3_ = _local_1_["cmd"] local split = _local_3_["split"] local diffsplit = _local_3_["diffsplit"]
 local _local_4_ = _local_1_["fn"] local expand = _local_4_["expand"] local fnamemodify = _local_4_["fnamemodify"] local glob = _local_4_["glob"] local isdirectory = _local_4_["isdirectory"]
 local _local_5_ = _local_1_["keymap"] local kset = _local_5_["set"]


 local default_config = {remotes = {}, mapping = nil, project_file_schemes = {}, scheme_replacements = {file = {}, dir = {}}}




 local project_file_schemes = default_config.project_file_schemes
 local scheme_replacements = default_config.scheme_replacements
 local remotes = default_config.remotes

 local function set_remotes(remote_map) _G.assert((nil ~= remote_map), "Missing argument remote-map on fennel/src/compare-remotes.fnl:21")
 do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for name, path_map in pairs(remote_map) do
 local val_19_auto = {name, path_map} if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end remotes = tbl_17_auto end return nil end

 local function get_remotes() local tbl_14_auto = {}
 for _, _7_ in ipairs(remotes) do local _each_8_ = _7_ local name = _each_8_[1] local path_map = _each_8_[2]
 local _9_, _10_ = name, path_map if ((nil ~= _9_) and (nil ~= _10_)) then local k_15_auto = _9_ local v_16_auto = _10_ tbl_14_auto[k_15_auto] = v_16_auto else end end return tbl_14_auto end

 local function replace_scheme(path, replacements) _G.assert((nil ~= replacements), "Missing argument replacements on fennel/src/compare-remotes.fnl:29") _G.assert((nil ~= path), "Missing argument path on fennel/src/compare-remotes.fnl:29")
 local scheme = string.gsub(path, "^(.+)://.+$", "%1")
 local replacement = replacements[scheme]
 if replacement then
 return string.gsub(path, "^.+://", (replacement .. "://")) else
 return path end end

 local function get_remote_path(remote_prefix, path, dir_3f) _G.assert((nil ~= dir_3f), "Missing argument dir? on fennel/src/compare-remotes.fnl:36") _G.assert((nil ~= path), "Missing argument path on fennel/src/compare-remotes.fnl:36") _G.assert((nil ~= remote_prefix), "Missing argument remote-prefix on fennel/src/compare-remotes.fnl:36")
 local replacements local _13_ if dir_3f then _13_ = "dir" else _13_ = "file" end replacements = scheme_replacements[_13_]
 local path_prefix = replace_scheme(remote_prefix, replacements)
 local function _15_() if endswith(path_prefix, "/") then return "" else return "/" end end return (path_prefix .. _15_() .. path) end

 local function open_diff(local_path, remote_prefix) _G.assert((nil ~= remote_prefix), "Missing argument remote-prefix on fennel/src/compare-remotes.fnl:41") _G.assert((nil ~= local_path), "Missing argument local-path on fennel/src/compare-remotes.fnl:41")
 local dir_3f = (1 == isdirectory(local_path))
 local remote_path = get_remote_path(remote_prefix, local_path, dir_3f)
 local tab = nvim_tabpage_get_number(0)
 split({mods = {tab = tab, silent = true}})
 return diffsplit({mods = {vertical = true, silent = true}, remote_path}) end

 local function entry_selected(local_path, _3fchoice) _G.assert((nil ~= local_path), "Missing argument local-path on fennel/src/compare-remotes.fnl:48")
 if _3fchoice then
 local _let_16_ = _3fchoice local _ = _let_16_[1] local remote_prefix = _let_16_[2]
 return open_diff(local_path, remote_prefix) else return nil end end

 local function open_remote_selection(local_path) _G.assert((nil ~= local_path), "Missing argument local-path on fennel/src/compare-remotes.fnl:53")
 local prompt = ("Select remote to compare " .. local_path .. " against")
 local function _18_(_241) return (_241)[1] end
 local function _19_(...) return entry_selected(local_path, ...) end return vim.ui.select(remotes, {prompt = prompt, format_item = _18_}, _19_) end

 local function project_file_3f(path) _G.assert((nil ~= path), "Missing argument path on fennel/src/compare-remotes.fnl:58")
 return (not startswith(path, "/") and ("" ~= glob(path))) end

 local function project_file_scheme_3f(path) _G.assert((nil ~= path), "Missing argument path on fennel/src/compare-remotes.fnl:61")
 local scheme = string.match(path, "^(.+)://")
 return (not scheme or tbl_contains(project_file_schemes, scheme)) end

 local function buf_path__3erelative_project_path(buf_path) _G.assert((nil ~= buf_path), "Missing argument buf-path on fennel/src/compare-remotes.fnl:65")
 local path_without_scheme = string.gsub(buf_path, "^.+://", "")
 local relative_path = fnamemodify(path_without_scheme, ":.")
 if (project_file_3f(relative_path) and project_file_scheme_3f(buf_path)) then
 return relative_path else return nil end end

 local function compare_file(path, _3fremote) _G.assert((nil ~= path), "Missing argument path on fennel/src/compare-remotes.fnl:71")
 if _3fremote then
 return open_diff(path, _3fremote) else
 return open_remote_selection(path) end end

 local function compare_remotes(_3fremote)
 local buf_path = expand("%:p")
 local project_file_path = buf_path__3erelative_project_path(buf_path)
 if project_file_path then
 return compare_file(project_file_path, _3fremote) else
 return nvim_echo({{("Not a project file: " .. buf_path), "ErrorMsg"}}, false, {}) end end

 local function setup(_3fconfig)
 local config = (_3fconfig or {})





 local _24_ do local t_23_ = config.mapping if (nil ~= t_23_) then t_23_ = (t_23_).key else end _24_ = t_23_ end
 local _27_ do local t_26_ = config.mapping if (nil ~= t_26_) then t_26_ = (t_26_).opts else end _27_ = t_26_ end validate({project_file_schemes = {config.project_file_schemes, {"nil", "table"}}, scheme_replacements = {config.scheme_replacements, {"nil", "table"}}, remotes = {config.remotes, {"nil", "table"}}, mapping = {config.mapping, {"nil", "table"}}, ["mapping.key"] = {_24_, {"nil", "string"}}, ["mapping.opts"] = {_27_, {"nil", "table"}}})
 if config.project_file_schemes then
 project_file_schemes = config.project_file_schemes else end
 local _31_ do local t_30_ = config.scheme_replacements if (nil ~= t_30_) then t_30_ = (t_30_).file else end _31_ = t_30_ end if _31_ then
 scheme_replacements.file = config.scheme_replacements.file else end
 local _35_ do local t_34_ = config.scheme_replacements if (nil ~= t_34_) then t_34_ = (t_34_).dir else end _35_ = t_34_ end if _35_ then
 scheme_replacements.dir = config.scheme_replacements.dir else end
 if config.remotes then
 set_remotes(config.remotes) else end
 local _40_ do local t_39_ = config.mapping if (nil ~= t_39_) then t_39_ = (t_39_).key else end _40_ = t_39_ end if _40_ then
 local user_opts = (config.mapping.opts or {})
 local default_opts = {desc = "Compare with remote"}
 local opts = tbl_extend("force", default_opts, user_opts)
 return kset("n", config.mapping.key, compare_remotes, opts) else return nil end end

 return {setup = setup, set_remotes = set_remotes, get_remotes = get_remotes, compare_remotes = compare_remotes}
