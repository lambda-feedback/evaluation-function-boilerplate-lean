import Lean.Data.Json
import Lean.Data.Json.FromToJson

open Lean Json System

-- Define a structure for the Params object
structure Params where
  correct_response_feedback : Option String := "Correct"
  incorrect_response_feedback : Option String := "Incorrect"
  deriving FromJson, ToJson

-- Define a structure for the InputData object with custom JSON field names
structure InputData where
  command : String
  response : String
  answer : String
  params : Option Params
  deriving FromJson, ToJson

-- Define a structure for the Result object
structure Result where
  is_correct : Bool
  feedback : String
  deriving ToJson

-- Define a structure for the OutputData object
structure OutputData where
  command : String
  result : Result
  deriving ToJson

-- Function to compare the response and answer with given tolerance
def compareValues (response : String) (answer : String) : Bool :=
  response == answer

-- Function to process input data and generate output data
def processInputData (inputData : InputData) : OutputData :=
  let params := inputData.params.getD {}
  let isCorrect := compareValues inputData.response inputData.answer
  let feedback := if isCorrect then params.correct_response_feedback.getD "Correct!" else params.incorrect_response_feedback.getD "Incorrect!"
  let result := { is_correct := isCorrect, feedback := feedback }
  { command := inputData.command, result := result }

-- Function to read JSON from a file and parse it into InputData
def readInputData (inputFile : String) : IO (Except String InputData) := do
  let inputJson ← IO.FS.readFile inputFile
  match Json.parse inputJson with
  | Except.ok json =>
    match fromJson? json with
    | Except.ok inputData => pure (Except.ok inputData)
    | Except.error err => pure (Except.error s!"Failed to parse input data: {err}")
  | Except.error err => pure (Except.error s!"Failed to parse input JSON: {err}")

-- Function to write OutputData to a file as JSON
def writeOutputData (outputFile : String) (outputData : OutputData) : IO Unit := do
  let outputJson := toJson outputData
  IO.FS.writeFile outputFile outputJson.pretty

-- Main function
def main (args : List String) : IO UInt32 := do
  if args.length < 2 then
    IO.eprintln "Error: Insufficient arguments. Usage: evaluation_function <input_file> <output_file>"
    pure 1
  else
    let inputFile := args.get! 0
    let outputFile := args.get! 1
    match ← readInputData inputFile with
    | Except.ok inputData =>
      if inputData.command != "eval" then
        IO.eprintln "Error: Command not supported"
      else
        let outputData := processInputData inputData
        writeOutputData outputFile outputData
    | Except.error err =>
      IO.eprintln err
    pure 0
