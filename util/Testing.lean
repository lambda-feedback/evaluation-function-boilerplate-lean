import Lean
import Lean.Meta

open Lean System Meta

namespace Testing

structure TestResult where
  total : Nat
  passed : Nat
  failed : Nat
  errors : Nat

def TestResult.zero : TestResult := { total := 0, passed := 0, failed := 0, errors := 0 }

def TestResult.add (r1 r2 : TestResult) : TestResult :=
  { total := r1.total + r2.total, passed := r1.passed + r2.passed, failed := r1.failed + r2.failed, errors := r1.errors + r2.errors }

def TestResult.success (r : TestResult) : Bool := r.failed == 0 && r.errors == 0

inductive Res where
  | ok
  | fail (msg : String)
  | error (msg : String)

class Runnable (α : Type) where
  name : α -> String
  run : α -> IO TestResult

structure Test where
  name : String
  test : IO Res

instance : Runnable Test where
  name t := t.name
  run t := do
    let res ← t.test
    match res with
    | Res.ok =>
      IO.println s!"[PASSED] {t.name}"
      return { total := 1, passed := 1, failed := 0, errors := 0 }
    | Res.fail msg =>
      IO.println s!"[FAILED] {t.name}: {msg}"
      return { total := 1, passed := 0, failed := 1, errors := 0 }
    | Res.error msg =>
      IO.println s!"[ERROR] {t.name}: {msg}"
      return { total := 1, passed := 0, failed := 0, errors := 1 }

structure TestSuite where
  name : String
  tests : List Test

instance : Runnable TestSuite where
  name ts := ts.name
  run ts := do
    IO.println s!"Running test suite {ts.name}"
    let results ← ts.tests.mapM Runnable.run
    let result := results.foldl TestResult.add TestResult.zero
    if result.total > 0 then
      IO.println s!"{ts.name}: {result.passed}/{result.total} tests passed, {result.failed} failed, {result.errors} errors"
    return result

-- Function to run a test and print the result
def t (name : String) (test : IO Res) : Test :=
  { name := name, test := test }

-- Function to run a suite of tests and print the results
def s (name : String) (tests : List Test) : TestSuite :=
  { name := name, tests := tests }

def run {α : Type} [Runnable α] (a : α) : IO Unit := do
  IO.println s!"Running tests..."
  let result ← Runnable.run a
  if result.total = 0 then
    throw $ IO.userError "No tests found"
  else if result.failed > 0 || result.errors > 0 then
    throw $ IO.userError "Some tests failed or had errors"
  else
    IO.println "All tests passed!"

def exec {α : Type} [Runnable α] (a : α) : IO UInt32 :=
  try run a; pure 0
  catch e => IO.println e; pure 1

end Testing
