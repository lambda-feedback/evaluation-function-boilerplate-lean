import Lean.Data.Json
import Lean.Data.Json.FromToJson

open Lean Json System

-- Define a structure for the Params object
structure Params where
  tolerance : Float
  tolerance_is_absolute : Bool
  correct_response_feedback : String
  incorrect_response_feedback : String
  deriving FromJson, ToJson

-- Define a structure for the InputData object with custom JSON field names
structure InputData where
  command : String
  response : Float
  answer : Float
  params : Params

instance : FromJson InputData where
  fromJson? json := do
    let command ← json.getObjValAs? String "command"
    let response ← json.getObjValAs? Float "response"
    let answer ← json.getObjValAs? Float "answer"
    let params ← json.getObjValAs? Params "params"
    pure { command, response, answer, params }

instance : ToJson InputData where
  toJson data :=
    mkObj [
      ("command", toJson data.command),
      ("response", toJson data.response),
      ("answer", toJson data.answer),
      ("params", toJson data.params)
    ]

-- Define a structure for the Result object
structure Result where
  is_correct : Bool
  feedback : String
  error : Option Float := none
  deriving ToJson

-- Define a structure for the OutputData object
structure OutputData where
  command : String
  result : Result
  deriving ToJson

-- Function to compare the response and answer with given tolerance
def compareValues (response answer tolerance : Float) (absolute : Bool) : Bool :=
  if absolute then
    (Float.abs (response - answer)) <= tolerance
  else
    (Float.abs ((response - answer) / answer)) <= tolerance

-- Function to process input data and generate output data
def processInputData (inputData : InputData) : OutputData :=
  let isCorrect := compareValues inputData.response inputData.answer inputData.params.tolerance inputData.params.tolerance_is_absolute
  let feedback := if isCorrect then inputData.params.correct_response_feedback else inputData.params.incorrect_response_feedback
  let error := if isCorrect then none else some (Float.abs (inputData.response - inputData.answer))
  let result := { is_correct := isCorrect, feedback := feedback, error := error }
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
