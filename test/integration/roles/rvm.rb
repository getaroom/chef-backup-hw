name "rvm"
description "RVM"

run_list(
  "recipe[rvm::system_install]",
)

default_attributes({
  "rvm" => {
    "global_gems" => [{ "name" => "bundler", "version" => "1.11.2" }], # min version
    "branch" => "none",
    "default_ruby" => "system",
    # somewhere between 1.25.8 and 1.25.16 introduces a failure building patched 1.9.3
    "upgrade" => "1.25.7",
    "version" => "1.25.7",
    "install_rubies" => true,
  },
  "aide" => {
    "custom_rules" => [
      "=/usr/local/rvm$ VarDir",
      "/usr/local/rvm VarInode",
      "/usr/local/rvm/src/rvm/ VarFile",
    ],
  },
})
