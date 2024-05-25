import «Evaluation»

-- Main function
def main (args : List String) : IO UInt32 := do
  if args.length < 2 then
    IO.eprintln "Error: Insufficient arguments. Usage: evaluation_function <input_file> <output_file>"
    pure 1
  else
    let inputFile := args.get! 0
    let outputFile := args.get! 1
    match ← handle inputFile outputFile with
    | Except.ok _ =>
      IO.eprintln "Evaluation successful!"
      pure 0
    | Except.error err =>
      IO.eprintln err
      pure 1
