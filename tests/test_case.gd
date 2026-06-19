# Minimal assertion base for headless tests.
#
# A test file `extends "res://tests/test_case.gd"` and defines methods named
# `test_*`. The runner (run_tests.gd) instantiates the file, injects `tree`,
# and calls each test method. Assertions record failures rather than aborting,
# so one method reports every problem it finds.
extends RefCounted

# Injected by the runner; used by tests that need to add nodes to the tree.
var tree: SceneTree = null

var failures: Array[String] = []


func reset() -> void:
  failures.clear()


func fail(message: String) -> void:
  failures.append(message)


func assert_true(condition: bool, message: String = "") -> void:
  if not condition:
    fail("assert_true failed. %s" % message)


func assert_false(condition: bool, message: String = "") -> void:
  if condition:
    fail("assert_false failed. %s" % message)


func assert_eq(actual, expected, message: String = "") -> void:
  if actual != expected:
    fail("assert_eq failed: expected `%s`, got `%s`. %s" % [expected, actual, message])


func assert_ne(actual, unexpected, message: String = "") -> void:
  if actual == unexpected:
    fail("assert_ne failed: got `%s`. %s" % [actual, message])


func assert_not_null(value, message: String = "") -> void:
  if value == null:
    fail("assert_not_null failed. %s" % message)


func assert_null(value, message: String = "") -> void:
  if value != null:
    fail("assert_null failed: got `%s`. %s" % [value, message])


func assert_same(actual, expected, message: String = "") -> void:
  if not is_same(actual, expected):
    fail("assert_same failed: not the same object. %s" % message)
