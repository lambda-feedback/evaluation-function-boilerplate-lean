import «Testing»
import «Evaluation»
import Lean.Meta
import Lean.Data.Json
import Lean.Data.Json.FromToJson

open Lean System Meta Testing

def TestEqualStrings : IO Res := do
  return if compareValues "test" "test" then Res.ok else Res.fail "Expected true, got false"

def TestDifferentStrings : IO Testing.Res := do
  return if compareValues "test" "TEST" then Res.fail "Expected false, got true" else Res.ok

def TestCorrectResponseDefaultFeedback : IO Testing.Res := do
  let input := { command := "eval", response := "42", answer := "42", params := none }
  let expected := { command := "eval", result := { is_correct := true, feedback := "Correct" } }
  return if processInputData input == expected then Res.ok else Res.fail "Expected true, got false"

def TestIncorrectResponseDefaultFeedback : IO Testing.Res := do
  let input := { command := "eval", response := "42", answer := "24", params := none }
  let expected := { command := "eval", result := { is_correct := false, feedback := "Incorrect" } }
  return if processInputData input == expected then Res.ok else Res.fail "Expected true, got false"

def TestCorrectResponseCustomFeedback : IO Testing.Res := do
  let params := { correct_response_feedback := some "Well done!" }
  let input := { command := "eval", response := "42", answer := "42", params := some params }
  let expected := { command := "eval", result := { is_correct := true, feedback := "Well done!" } }
  return if processInputData input == expected then Res.ok else Res.fail "Expected true, got false"

def TestIncorrectResponseCustomFeedback : IO Testing.Res := do
  let params := { incorrect_response_feedback := some "Try again." }
  let input := { command := "eval", response := "42", answer := "24", params := some params }
  let expected := { command := "eval", result := { is_correct := false, feedback := "Try again." } }
  return if processInputData input == expected then Res.ok else Res.fail "Expected true, got false"


-- def testJsonParsing : IO Unit := do
--   let json := "{\"command\":\"eval\",\"response\":\"42\",\"answer\":\"42\",\"params\":{\"correct_response_feedback\":\"Great!\",\"incorrect_response_feedback\":\"Not quite.\"}}"
--   match Json.parse json with
--   | Except.ok json =>
--     match fromJson? json with
--     | Except.ok (inputData : InputData) =>
--       runTest "Parse InputData from JSON (command)" (inputData.command = "eval")
--       runTest "Parse InputData from JSON (response)" (inputData.response = "42")
--       runTest "Parse InputData from JSON (answer)" (inputData.answer = "42")
--       runTest "Parse InputData from JSON (correct feedback)" ((inputData.params.getD {}).correct_response_feedback == "Great!")
--       runTest "Parse InputData from JSON (incorrect feedback)" ((inputData.params.getD {}).incorrect_response_feedback == "Not quite.")
--     | Except.error _ =>
--       runTest "Parse InputData from JSON" false

--     let outputData : OutputData := { command := "eval", result := { is_correct := true, feedback := "Correct!" } }
--     let expectedJson := "{\"command\":\"eval\",\"result\":{\"is_correct\":true,\"feedback\":\"Correct!\"}}"
--     runTest "Generate OutputData to JSON" ((toJson outputData).compress == expectedJson)
--   | Except.error _ =>
--     runTest "Parse JSON" false

def suite := (Testing.s "Evaluation" [
  Testing.t "TestEqualStrings" TestEqualStrings,
  Testing.t "TestDifferentStrings" TestDifferentStrings,
  Testing.t "TestCorrectResponseDefaultFeedback" TestCorrectResponseDefaultFeedback,
  Testing.t "TestIncorrectResponseDefaultFeedback" TestIncorrectResponseDefaultFeedback,
  Testing.t "TestCorrectResponseCustomFeedback" TestCorrectResponseCustomFeedback,
  Testing.t "TestIncorrectResponseCustomFeedback" TestIncorrectResponseCustomFeedback
])

def main : IO UInt32 := do
  Testing.exec suite
