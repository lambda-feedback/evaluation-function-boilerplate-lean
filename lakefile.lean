import Lake
open Lake DSL

package «evaluation_function_template» where
  -- add package configuration options here

@[default_target]
lean_exe «evaluation_function_template» where
  root := `Main
