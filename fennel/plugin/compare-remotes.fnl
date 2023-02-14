(local {:api {: nvim_create_user_command}} vim)

(local {: compare_remotes} (require :compare-remotes))

(nvim_create_user_command :CompareRemotes
                          (fn [{:fargs [remote-prefix]}]
                            (compare_remotes remote-prefix))
                          {:nargs "?"})
