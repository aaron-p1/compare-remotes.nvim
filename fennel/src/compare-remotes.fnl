(local {: endswith
        : startswith
        : tbl_contains
        : tbl_deep_extend
        :api {: nvim_tabpage_get_number : nvim_echo : nvim_create_user_command}
        :cmd {: split : diffsplit}
        :fn {: expand : fnamemodify : glob : isdirectory}
        :keymap {:set kset}} vim)

(local default-config
       {:remotes {}
        :mapping {:key :<Leader>cr :opts {:desc "Compare remote file"}}
        :project_file_schemes []
        :scheme_replacements {:file {} :dir {}}})

(var project-file-schemes default-config.project_file_schemes)
(var scheme-replacements default-config.scheme_replacements)
(var remotes default-config.remotes)

(lambda set-remotes [remote-map]
  (set remotes (icollect [name path-map (pairs remote-map)]
                 [name path-map])))

(lambda get-remotes []
  (collect [_ [name path-map] (ipairs remotes)]
    (values name path-map)))

(lambda replace-scheme [path replacements]
  (let [scheme (string.gsub path "^(.+)://.+$" "%1")
        replacement (. replacements scheme)]
    (if replacement
        (string.gsub path "^.+://" (.. replacement "://"))
        path)))

(lambda get-remote-path [remote-prefix path dir?]
  (let [replacements (. scheme-replacements (if dir? :dir :file))
        path-prefix (replace-scheme remote-prefix replacements)]
    (.. path-prefix (if (endswith path-prefix "/") "" "/") path)))

(lambda open-diff [local-path remote-prefix]
  (let [dir? (= 1 (isdirectory local-path))
        remote-path (get-remote-path remote-prefix local-path dir?)
        tab (nvim_tabpage_get_number 0)]
    (split {:mods {: tab :silent true}})
    (diffsplit {1 remote-path :mods {:vertical true :silent true}})))

(lambda entry-selected [local-path ?choice]
  (when ?choice
    (let [[_ remote-prefix] ?choice]
      (open-diff local-path remote-prefix))))

(lambda open-remote-selection [local-path]
  (let [prompt (.. "Select remote to compare " local-path " against")]
    (vim.ui.select remotes {: prompt :format_item #(. $1 1)}
                   (partial entry-selected local-path))))

(lambda project-file? [path]
  (and (not (startswith path "/")) (not= "" (glob path))))

(lambda project-file-scheme? [path]
  (let [scheme (string.match path "^(.+)://")]
    (or (not scheme) (tbl_contains project-file-schemes scheme))))

(lambda buf-path->relative-project-path [buf-path]
  (let [path-without-scheme (string.gsub buf-path "^.+://" "")
        relative-path (fnamemodify path-without-scheme ":.")]
    (if (and (project-file? relative-path) (project-file-scheme? buf-path))
        relative-path)))

(lambda compare-file [path ?remote]
  (if ?remote
      (open-diff path ?remote)
      (open-remote-selection path)))

(fn compare-remotes [?remote]
  (let [buf-path (expand "%:p")
        project-file-path (buf-path->relative-project-path buf-path)]
    (if project-file-path
        (compare-file project-file-path ?remote)
        (nvim_echo [[(.. "Not a project file: " buf-path) :ErrorMsg]] false {}))))

(lambda setup [?user-config]
  (let [user-config (or ?user-config {})
        config (tbl_deep_extend :force default-config user-config)]
    (set project-file-schemes config.project_file_schemes)
    (set scheme-replacements config.scheme_replacements)
    (set-remotes config.remotes)
    (when config.mapping
      (kset :n config.mapping.key compare-remotes config.mapping.opts))))

{: setup
 :set_remotes set-remotes
 :get_remotes get-remotes
 :compare_remotes compare-remotes}
