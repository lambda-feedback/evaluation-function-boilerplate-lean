import Lake
open Lake DSL

package «evaluation_function» where
  -- add package configuration options here

@[default_target]
lean_exe «evaluation_function» where
  root := `Main
