 local _local_1_ = vim local _local_2_ = _local_1_["api"] local nvim_create_user_command = _local_2_["nvim_create_user_command"]

 local _local_3_ = require("compare-remotes") local compare_remotes = _local_3_["compare_remotes"]


 local function _7_(_4_) local _arg_5_ = _4_ local _arg_6_ = _arg_5_["fargs"] local remote_prefix = _arg_6_[1]
 return compare_remotes(remote_prefix) end return nvim_create_user_command("CompareRemotes", _7_, {nargs = "?"})
