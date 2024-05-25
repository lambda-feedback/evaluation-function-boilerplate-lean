import Lake
open Lake DSL

require batteries from git "https://github.com/leanprover-community/batteries" @ "main"

package «evaluation» where
  -- add package configuration options here

lean_lib «Evaluation» where
  -- add library configuration options here
  srcDir := "./src"

lean_lib «Testing» where
  srcDir := "./util"

@[default_target]
lean_exe «evaluation» where
  root := `Main
  srcDir := "./src"
  -- `supportInterpreter` enables the use of the Lean interpreter
  -- by the executable (e.g., `Lean.Elab.runFrontend`) at the expense
  -- of increased binary size on Linux.
  -- supportInterpreter := true

@[test_runner]
lean_exe «tests» where
  root := `Main
  srcDir := "./tests"
