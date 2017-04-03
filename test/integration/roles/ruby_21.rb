name "ruby_21"
description "Install Ruby 2.1"

run_list(
  "role[rvm]",
  "recipe[gar_rvm_installer]",
)

default_attributes({
  "gar_rvm_installer" => {
    "rubies" => {"ruby-2.1.9" => { "rubygems_version" => "2.6.1", "global_gems" => { "bundler" => "1.11.2" }}},
  },
})
