name "kitchen_base"
description "only install enough for test kitchen"

run_list(
  "recipe[apt]"
)

default_attributes({
                     "apt" => {
                       "compile_time_update" => true,
                     },
                   })
