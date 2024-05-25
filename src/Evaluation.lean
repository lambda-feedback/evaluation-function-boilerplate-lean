import Lean.Data.Json
import Lean.Data.Json.FromToJson

open Lean System

-- Define a structure for the Params object
structure Params where
  correct_response_feedback : Option String := none
  incorrect_response_feedback : Option String := none
  deriving BEq, FromJson, ToJson

-- Define a structure for the InputData object with custom JSON field names
structure InputData where
  command : String
  response : String
  answer : String
  params : Option Params
  deriving BEq, FromJson, ToJson

-- Define a structure for the Result object
structure Result where
  is_correct : Bool
  feedback : String
  deriving BEq, ToJson

-- Define a structure for the OutputData object
structure OutputData where
  command : String
  result : Result
  deriving BEq, ToJson

-- Function to compare the response and answer with given tolerance
def compareValues (response : String) (answer : String) : Bool :=
  response == answer

-- Function to process input data and generate output data
def processInputData (inputData : InputData) : OutputData :=
  let params := inputData.params.getD {}
  let isCorrect := compareValues inputData.response inputData.answer
  let feedback := if isCorrect then (params.correct_response_feedback.getD "Correct") else (params.incorrect_response_feedback.getD "Incorrect")
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
  IO.FS.writeFile outputFile outputJson.compress

-- Main function
def handle (inputFile : String) (outputFile : String) : IO (Except String OutputData) := do
  match ← readInputData inputFile with
  | Except.ok inputData =>
    if inputData.command == "eval" then
      let outputData := processInputData inputData
      writeOutputData outputFile outputData
      pure (Except.ok outputData)
    else
      pure (Except.error "Command not supported")
  | Except.error err =>
    pure (Except.error err)
